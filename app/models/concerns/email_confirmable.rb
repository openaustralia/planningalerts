# typed: false
# frozen_string_literal: true

# Requires a field email, confirm_id and confirmed on model
module EmailConfirmable
  extend ActiveSupport::Concern

  included do
    validates :email, presence: true
    validates_email_format_of :email, on: :create
    before_create :set_confirm_info
    # Doing after_commit instead after_create so that sidekiq doesn't try
    # to see this before it properly exists. See
    # https://github.com/mperham/sidekiq/wiki/Problems-and-Troubleshooting#cannot-find-modelname-with-id12345
    after_commit :send_confirmation_email, on: :create

    scope(:confirmed, -> { where(confirmed: true) })
  end

  def send_confirmation_email
    ConfirmationMailer.confirm(self).deliver_later
  end

  protected

  def set_confirm_info
    # TODO: Should check that this is unique across all objects and if not try again
    self.confirm_id = Digest::MD5.hexdigest(rand.to_s + Time.zone.now.to_s)[0...20]
  end
end
