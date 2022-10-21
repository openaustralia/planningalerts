# typed: strict
# frozen_string_literal: true

class User < ApplicationRecord
  extend T::Sig

  validate :validate_email_domain

  # For sorbet
  include Devise::Models::Authenticatable

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable
  has_many :api_keys, dependent: :destroy

  sig { params(notification: T.untyped, args: T.untyped).void }
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  private

  sig { void }
  def validate_email_domain
    domain = Mail::Address.new(email).domain

    return if domain != "mailinator.com"

    errors.add(:email, "is not available. Please use another email address.")
  end
end
