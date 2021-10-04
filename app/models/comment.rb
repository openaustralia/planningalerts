# typed: strict
# frozen_string_literal: true

require "rest-client"

class Comment < ApplicationRecord
  extend T::Sig

  belongs_to :application
  has_many :reports, dependent: :destroy
  validates :name, presence: true
  validates :text, presence: true
  validates :address, presence: true

  include EmailConfirmable
  scope(:visible, -> { where(confirmed: true, hidden: false) })
  scope(:confirmed, -> { where(confirmed: true) })
  scope(:in_past_week, -> { where("created_at > ?", 7.days.ago) })

  counter_culture :application,
                  column_name: proc { |comment| comment.visible? ? "visible_comments_count" : nil },
                  column_names: {
                    "comments.confirmed = true and comments.hidden = false" => "visible_comments_count"
                  }

  # TODO: Change confirmed in schema to be null: false

  sig { returns(T::Boolean) }
  def visible?
    !!confirmed && !hidden
  end

  sig { void }
  def confirm!
    return if confirmed

    update!(confirmed: true, confirmed_at: Time.current)
    send_comment!
  end

  sig { void }
  def send_comment!
    CommentMailer.notify_authority(self).deliver_later
  end

  sig { returns(T.nilable(String)) }
  def recipient_display_name
    application&.authority&.full_name
  end
end
