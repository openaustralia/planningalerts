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

  validates :name, presence: true
  validates :text, presence: true
  validates :address, presence: true
  validates :user_id, uniqueness: { scope: %i[application_id published] }, unless: :published?

  scope(:published, -> { where(published: true) })
  scope(:visible, -> { where(published: true, hidden: false) })
  scope(:in_past_week, -> { where("published_at > ?", 7.days.ago) })

  delegate :email, to: :user
  delegate :comment_recipient_full_name, to: :application

  # TODO: Rename the counter to published_comments_count
  counter_culture :application,
                  column_name: proc { |comment| comment.published? ? "visible_comments_count" : nil },
                  column_names: {
                    "comments.published = true" => "visible_comments_count"
                  }

  sig { returns(T::Boolean) }
  def visible?
    !!published && !hidden
  end

  sig { void }
  def send_comment!
    CommentMailer.notify_authority(self).deliver_later
  end
end
