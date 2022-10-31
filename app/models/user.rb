# typed: strict
# frozen_string_literal: true

class User < ApplicationRecord
  extend T::Sig

  validate :validate_email_domain

  # For sorbet
  include Devise::Models::Authenticatable
  include Devise::Models::Confirmable

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

  private

  sig { returns(T::Boolean) }
  def password_required?
    return false if @temporarily_allow_empty_password

    super
  end

  sig { void }
  def validate_email_domain
    domain = Mail::Address.new(email).domain

    return if domain != "mailinator.com"

    errors.add(:email, "is not available. Please use another email address.")
  end
end
