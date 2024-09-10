# typed: strict
# frozen_string_literal: true

class User < ApplicationRecord
  extend T::Sig

  rolify
  validate :validate_email_domain

  # For sorbet
  include Devise::Models::Authenticatable
  include Devise::Models::Confirmable
  include Devise::Models::Recoverable
  include Devise::Models::Validatable
  extend Devise::Models::Validatable::ClassMethods
  extend Rolify

  # Include default devise modules. Others available are:
  # :token_authenticatable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable, :lockable
  has_many :api_keys, dependent: :destroy
  has_many :alerts, dependent: :destroy
  # If a user is destroyed we want to keep the comments because they
  # are part of the public record
  has_many :comments, dependent: :nullify
  # Same for reports but they're not public
  has_many :reports, dependent: :nullify
  has_many :contact_messages, dependent: :nullify

  # rubocop:disable Style/ArgumentsForwarding
  # TODO: Arguments forwarding doesn't seem to be supported by sorbet right now?
  sig { params(notification: T.untyped, args: T.untyped).void }
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
  # rubocop:enable Style/ArgumentsForwarding

  # This is currently used when creating users via an alert
  # TODO: Remove this as soon as users are purely being created by people registering
  sig { void }
  def temporarily_allow_empty_password!
    @temporarily_allow_empty_password = T.let(true, T.nilable(T::Boolean))
  end

  sig { returns(T::Boolean) }
  def requires_activation?
    encrypted_password.blank?
  end

  # Returns the name of the user. If that isn't set just returns the email
  # We want to use this very sparingly. The only place it really makes sense
  # is in the nav bar. In places where we are referring to people by name
  # it doesn't make sense to use their email address if their name isn't
  # available. It makes much more sense in that case to just have a more
  # generic "Hello!" rather than "Hello foo@foo.com!".
  sig { returns(String) }
  def name_with_fallback
    name.presence || email
  end

  sig { void }
  def send_activation_instructions
    Users::ActivationMailer.notify(self, set_reset_password_token).deliver_later!
  end

  private

  sig { returns(T::Boolean) }
  def password_required?
    return false if @temporarily_allow_empty_password

    super
  end

  sig { void }
  def validate_email_domain
    return unless IsEmailAddressBannedService.call(email:)

    errors.add(:email, "is not allowed. Please contact us if you think this is in error.")
  end
end
