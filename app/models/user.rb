# typed: strict
# frozen_string_literal: true

class User < ApplicationRecord
  extend T::Sig

  validate :validate_email_domain

  # For sorbet
  include Devise::Models::Authenticatable
  include Devise::Models::Confirmable
  include Devise::Models::Recoverable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable
  has_many :api_keys, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :comments, dependent: :destroy

  sig { params(notification: T.untyped, args: T.untyped).void }
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # This is currently used when creating users via an alert
  # TODO: Remove this as soon as users are purely being created by people registering
  sig { void }
  def temporarily_allow_empty_password!
    @temporarily_allow_empty_password = T.let(true, T.nilable(T::Boolean))
  end

  sig { returns(T::Boolean) }
  def requires_activation?
    from_alert_or_comment && encrypted_password.blank?
  end

  # Returns the name of the user. If that isn't set just returns the email
  sig { returns(String) }
  def name_with_fallback
    name.presence || email
  end

  sig { void }
  def send_activation_instructions
    _token = set_reset_password_token
    # TODO: Actually send email here
  end

  private

  sig { returns(T::Boolean) }
  def password_required?
    return false if @temporarily_allow_empty_password

    super
  end

  sig { void }
  def validate_email_domain
    return unless IsEmailAddressBannedService.call(email: email)

    errors.add(:email, "is not allowed. Please contact us if you think this is in error.")
  end
end
