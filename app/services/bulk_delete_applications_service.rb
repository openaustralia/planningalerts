# typed: strict
# frozen_string_literal: true

# Bulk deletes applications for an authority whose council_reference starts
# with the given prefix. Used by the planningalerts:bulk_delete_applications
# rake task. See https://github.com/openaustralia/planningalerts/issues/2155
class BulkDeleteApplicationsService
  extend T::Sig

  # A summary of an application that the service acted on (or would act on)
  class Item < T::Struct
    const :id, Integer
    const :council_reference, String
    const :address, String
    const :comments_count, Integer
  end

  class Result < T::Struct
    const :dry_run, T::Boolean
    # Applications that were deleted (or would be deleted in a dry run)
    const :deleted, T::Array[Item]
    # Applications skipped because they have comments (and delete_comments was not set)
    const :skipped_comments, T::Array[Item]
    # Applications skipped because they are the target of an application redirect
    const :skipped_redirect_target, T::Array[Item]
  end

  sig do
    params(
      authority: Authority,
      council_reference_prefix: String,
      dry_run: T::Boolean,
      delete_comments: T::Boolean
    ).returns(Result)
  end
  def self.call(authority:, council_reference_prefix:, dry_run:, delete_comments: false)
    new(authority:, council_reference_prefix:, dry_run:, delete_comments:).call
  end

  sig do
    params(
      authority: Authority,
      council_reference_prefix: String,
      dry_run: T::Boolean,
      delete_comments: T::Boolean
    ).void
  end
  def initialize(authority:, council_reference_prefix:, dry_run:, delete_comments:)
    @authority = authority
    @council_reference_prefix = council_reference_prefix
    @dry_run = dry_run
    @delete_comments = delete_comments
  end

  sig { returns(Result) }
  def call
    raise ArgumentError, "council_reference_prefix can't be blank" if council_reference_prefix.blank?

    deleted = T.let([], T::Array[Item])
    skipped_comments = T.let([], T::Array[Item])
    skipped_redirect_target = T.let([], T::Array[Item])

    # Fetch redirect-target IDs once to avoid N+1 queries in the loop
    redirect_target_ids = T.let(
      ApplicationRedirect.where(redirect_application_id: matching_applications).pluck(:redirect_application_id).to_set,
      T::Set[Integer]
    )

    matching_applications.preload(:comments).find_each do |application|
      comments_count = application.comments.size

      item = Item.new(
        id: application.id,
        council_reference: application.council_reference,
        address: application.address,
        comments_count:
      )

      if redirect_target_ids.include?(application.id)
        # Deleting these would violate a foreign key constraint on
        # application_redirects so they need to be handled manually
        skipped_redirect_target << item
      elsif comments_count.positive? && !delete_comments
        skipped_comments << item
      else
        delete(application) unless dry_run
        deleted << item
      end
    end

    Result.new(dry_run:, deleted:, skipped_comments:, skipped_redirect_target:)
  end

  private

  sig { returns(Authority) }
  attr_reader :authority

  sig { returns(String) }
  attr_reader :council_reference_prefix

  sig { returns(T::Boolean) }
  attr_reader :dry_run

  sig { returns(T::Boolean) }
  attr_reader :delete_comments

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
      application.comments.find_each(&:destroy!) if delete_comments
      application.destroy!
    end
  end
end
