# typed: strict
# frozen_string_literal: true

require "rest-client"

class Comment < ApplicationRecord
  extend T::Sig

  belongs_to :application
  # The only situation in which a user is not attached to a comment is if the user has been deleted
  # See app/models/user.rb:23
  belongs_to :user, optional: true
  has_many :reports, dependent: :destroy

  # TODO: Remove accepts_nested_attributes_for after users purely sign up for alerts by being logged in
  accepts_nested_attributes_for :user

  validates :name, presence: true
  validates :text, presence: true
  validates :address, presence: true
  validates :user_id, uniqueness: { scope: %i[application_id previewed] }, unless: :previewed?

  before_create :set_confirm_info

  scope(:confirmed, -> { where(confirmed: true) })
  scope(:confirmed_and_previewed, -> { where(confirmed: true, previewed: true) })
  scope(:visible, -> { where(confirmed: true, previewed: true, hidden: false) })
  scope(:in_past_week, -> { where("published_at > ?", 7.days.ago) })

  delegate :email, to: :user
  delegate :comment_recipient_full_name, to: :application

  # TODO: Rename the counter to confirmed_comments_count
  counter_culture :application,
                  column_name: proc { |comment| comment.confirmed? && comment.previewed? ? "visible_comments_count" : nil },
                  column_names: {
                    "comments.confirmed = true and comments.previewed = true" => "visible_comments_count"
                  }

  # TODO: Change confirmed in schema to be null: false

  sig { returns(T::Boolean) }
  def visible?
    !!confirmed && !!previewed && !hidden
  end

  sig { void }
  def send_comment!
    CommentMailer.notify_authority(self).deliver_later
  end

  private

  sig { void }
  def set_confirm_info
    # TODO: Should check that this is unique across all objects and if not try again
    self.confirm_id = Digest::MD5.hexdigest(Kernel.rand.to_s + Time.zone.now.to_s)[0...20]
  end
end
