# Requires an email method, confirm_id field and confirmed on model
module EmailConfirmableViaMethod
  extend ActiveSupport::Concern

  included do
    validate :has_public_method_email?
    validate :email_method_is_valid_email?
    validates_email_format_of :email, on: :create
    before_create :set_confirm_info
    after_create :send_confirmation_email

    scope :confirmed, -> { where(confirmed: true) }
  end

  def send_confirmation_email
    ConfirmationMailer.confirm(self.theme, self).deliver_later
  end

  protected

  def has_public_method_email?
    public_methods.include?(:email)
  end

  def email_method_is_valid_email?
    ValidatesEmailFormatOf::validate_email_format(email).nil?
  end

  def set_confirm_info
    # TODO: Should check that this is unique across all objects and if not try again
    self.confirm_id = Digest::MD5.hexdigest(rand.to_s + Time.now.to_s)[0...20]
  end
end
