# typed: strict
# frozen_string_literal: true

# Bulk moderates (deletes, hides or unhides) applications for an authority
# whose council_reference starts with the given prefix. Used by the
# planningalerts:bulk_delete_applications, planningalerts:bulk_hide_applications
# and planningalerts:bulk_unhide_applications rake tasks.
# See https://github.com/openaustralia/planningalerts/issues/2155 and
# https://github.com/openaustralia/planningalerts/issues/2191
class BulkModerateApplicationsService
  extend T::Sig

  class Mode < T::Enum
    enums do
      Delete = new
      Hide = new
      Unhide = new
    end
  end

  # A summary of an application that the service acted on (or would act on)
  class Item < T::Struct
    const :id, Integer
    const :council_reference, String
    const :address, String
    const :comments_count, Integer
  end

  class Result < T::Struct
    const :mode, Mode
    const :dry_run, T::Boolean
    # Applications that were deleted, hidden or unhidden (or would be in a dry run)
    const :changed, T::Array[Item]
    # Applications skipped because they have comments (delete mode without delete_comments)
    const :skipped_comments, T::Array[Item]
    # Applications skipped because they are the target of an application redirect (delete mode)
    const :skipped_redirect_target, T::Array[Item]
    # Applications skipped because they are already hidden (hide mode) or
    # already visible (unhide mode). Hiding never overwrites the hidden_reason
    # on an application that was already hidden, e.g. by hand in the admin
    const :skipped_unchanged, T::Array[Item]
  end

  sig do
    params(
      authority: Authority,
      council_reference_prefix: String,
      mode: Mode,
      dry_run: T::Boolean,
      delete_comments: T::Boolean,
      hidden_reason: T.nilable(String)
    ).returns(Result)
  end
  def self.call(authority:, council_reference_prefix:, mode:, dry_run:, delete_comments: false, hidden_reason: nil)
    new(authority:, council_reference_prefix:, mode:, dry_run:, delete_comments:, hidden_reason:).call
  end

  sig do
    params(
      authority: Authority,
      council_reference_prefix: String,
      mode: Mode,
      dry_run: T::Boolean,
      delete_comments: T::Boolean,
      hidden_reason: T.nilable(String)
    ).void
  end
  def initialize(authority:, council_reference_prefix:, mode:, dry_run:, delete_comments:, hidden_reason:)
    @authority = authority
    @council_reference_prefix = council_reference_prefix
    @mode = mode
    @dry_run = dry_run
    @delete_comments = delete_comments
    @hidden_reason = hidden_reason
  end

  sig { returns(Result) }
  def call
    raise ArgumentError, "council_reference_prefix can't be blank" if council_reference_prefix.blank?
    # hidden_reason is published word-for-word on the public page for each
    # hidden application so we don't want it silently falling back to the
    # default explanation when hiding in bulk
    raise ArgumentError, "hidden_reason can't be blank when hiding" if mode == Mode::Hide && hidden_reason.blank?
    raise ArgumentError, "hidden_reason only applies when hiding" if mode != Mode::Hide && hidden_reason.present?
    raise ArgumentError, "delete_comments only applies when deleting" if mode != Mode::Delete && delete_comments

    changed = T.let([], T::Array[Item])
    skipped_comments = T.let([], T::Array[Item])
    skipped_redirect_target = T.let([], T::Array[Item])
    skipped_unchanged = T.let([], T::Array[Item])

    # Fetch these up-front to avoid running two queries per application
    comment_counts = Comment.where(application_id: matching_applications.select(:id))
                            .group(:application_id).count
    redirect_target_ids = ApplicationRedirect.where(redirect_application_id: matching_applications.select(:id))
                                             .pluck(:redirect_application_id).to_set

    # Assigned to a local so sorbet can check the case statement covers every mode
    m = mode
    matching_applications.find_each do |application|
      item = Item.new(
        id: application.id,
        council_reference: application.council_reference,
        address: application.address,
        comments_count: comment_counts.fetch(application.id, 0)
      )

      case m
      when Mode::Delete
        if redirect_target_ids.include?(application.id)
          # Deleting these would violate a foreign key constraint on
          # application_redirects so they need to be handled manually
          skipped_redirect_target << item
        elsif item.comments_count.positive? && !delete_comments
          skipped_comments << item
        else
          delete(application) unless dry_run
          changed << item
        end
      when Mode::Hide
        if application.hidden
          skipped_unchanged << item
        else
          hide(application) unless dry_run
          changed << item
        end
      when Mode::Unhide
        if application.hidden
          unhide(application) unless dry_run
          changed << item
        else
          skipped_unchanged << item
        end
      else
        T.absurd(m)
      end
    end

    Result.new(mode:, dry_run:, changed:, skipped_comments:, skipped_redirect_target:, skipped_unchanged:)
  end

  private

  sig { returns(Authority) }
  attr_reader :authority

  sig { returns(String) }
  attr_reader :council_reference_prefix

  sig { returns(Mode) }
  attr_reader :mode

  sig { returns(T::Boolean) }
  attr_reader :dry_run

  sig { returns(T::Boolean) }
  attr_reader :delete_comments

  sig { returns(T.nilable(String)) }
  attr_reader :hidden_reason

  sig { returns(ActiveRecord::Relation) }
  def matching_applications
    authority.applications.where(
      "council_reference LIKE ?",
      "#{Application.sanitize_sql_like(council_reference_prefix)}%"
    )
  end

  sig { params(application: Application).void }
  def delete(application)
    Application.transaction do
      # Destroy in batches rather than destroy_all so we don't load every
      # comment into memory at once, while still running callbacks
      application.comments.find_each(&:destroy!) if delete_comments
      application.destroy!
    end
  end

  # Hiding and unhiding save each record individually (rather than using
  # update_all) so that searchkick's callbacks run. Application#should_index?
  # returns false when hidden, so hidden applications get removed from the
  # elasticsearch index and unhidden ones get added back. A bare update_all
  # would leave hidden applications still showing up in full text search.

  sig { params(application: Application).void }
  def hide(application)
    application.update!(hidden: true, hidden_reason:)
  end

  sig { params(application: Application).void }
  def unhide(application)
    application.update!(hidden: false, hidden_reason: nil)
  end
end
