# typed: strict
# frozen_string_literal: true

# A message staff publish to show as a bar across the top of the site. The body is HTML, which is sanitised when shown.
class Announcement < ApplicationRecord
  extend T::Sig

  has_paper_trail

  validates :body, presence: true
  validate :ends_after_it_starts

  # Published, and inside its optional start and end times
  scope :live, lambda { |at = Time.current|
    where(published: true)
      .where("starts_at IS NULL OR starts_at <= ?", at)
      .where("ends_at IS NULL OR ends_at > ?", at)
  }

  # Only one announcement shows at a time: the newest live one
  sig { returns(T.nilable(Announcement)) }
  def self.current
    live.order(created_at: :desc, id: :desc).first
  end

  private

  sig { void }
  def ends_after_it_starts
    starts = starts_at
    ends = ends_at
    return if starts.blank? || ends.blank? || ends > starts

    errors.add(:ends_at, "must be after the start")
  end
end
