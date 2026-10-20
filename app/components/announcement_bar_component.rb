# typed: strict
# frozen_string_literal: true

# The bar must never stop a page rendering. That includes the error pages, which use the main layout and are most likely
# to be shown when the database is struggling.
class AnnouncementBarComponent < ViewComponent::Base
  extend T::Sig

  # Runs before render?, and keeps the query out of the constructor
  sig { void }
  def before_render
    @announcement = T.let(load_announcement, T.nilable(Announcement))
  end

  sig { returns(T::Boolean) }
  def render?
    !@announcement.nil?
  end

  private

  sig { returns(T.nilable(Announcement)) }
  def load_announcement
    Announcement.current
  rescue ActiveRecord::ActiveRecordError => e
    Rails.logger.error("Announcement bar skipped: #{e.class}: #{e.message}")
    Sentry.capture_exception(e)
    nil
  end
end
