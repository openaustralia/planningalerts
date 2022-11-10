# typed: strict
# frozen_string_literal: true

require "rest-client"

class Comment < ApplicationRecord
  extend T::Sig

  belongs_to :application
  belongs_to :user
  has_many :reports, dependent: :destroy

  # TODO: Remove accepts_nested_attributes_for after users purely sign up for alerts by being logged in
  accepts_nested_attributes_for :user

  validates :name, presence: true
  validates :text, presence: true
  validates :address, presence: true

  before_create :set_confirm_info
  # Doing after_commit instead after_create so that sidekiq doesn't try
  # to see this before it properly exists. See
  # https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting#cannot-find-modelname-with-id12345
  after_commit :send_confirmation_email, on: :create, unless: :confirmed?

  scope(:confirmed, -> { where(confirmed: true) })
  scope(:visible, -> { where(confirmed: true, hidden: false) })
  scope(:in_past_week, -> { where("created_at > ?", 7.days.ago) })

  delegate :email, to: :user

  counter_culture :application,
                  column_name: proc { |comment| comment.visible? ? "visible_comments_count" : nil },
                  column_names: {
                    "comments.confirmed = true and comments.hidden = false" => "visible_comments_count"
                  }

  # TODO: Change confirmed in schema to be null: false

  sig { void }
  def send_confirmation_email
    ConfirmationMailer.confirm(self).deliver_later
  end

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

  private

  sig { void }
  def set_confirm_info
    # TODO: Should check that this is unique across all objects and if not try again
    self.confirm_id = Digest::MD5.hexdigest(Kernel.rand.to_s + Time.zone.now.to_s)[0...20]
  end
end
