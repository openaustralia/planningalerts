# frozen_string_literal: true

# Requires a field email, confirm_id and confirmed on model
module EmailConfirmable
  extend ActiveSupport::Concern

  included do
    validates_presence_of :email
    validates_email_format_of :email, on: :create
    before_create :set_confirm_info
    after_create :send_confirmation_email

    scope(:confirmed, -> { where(confirmed: true) })
  end

  def send_confirmation_email
    ConfirmationMailer.confirm(self).deliver_later
  end

  protected

  def set_confirm_info
    # TODO: Should check that this is unique across all objects and if not try again
    self.confirm_id = Digest::MD5.hexdigest(rand.to_s + Time.now.to_s)[0...20]
  end
end
