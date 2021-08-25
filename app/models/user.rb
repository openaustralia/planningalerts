# typed: strict
# frozen_string_literal: true

class User < ApplicationRecord
  extend T::Sig

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable
  after_create :create_api_key_object
  # TODO: Rename to :api_key once api key field on users have been removed
  has_one :api_key_object, class_name: "ApiKey", dependent: :destroy
  # Doing this for the benefit of activeadmin
  accepts_nested_attributes_for :api_key_object

  sig { params(notification: T.untyped, args: T.untyped).void }
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end
end
