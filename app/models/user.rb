# typed: strict
# frozen_string_literal: true

class User < ApplicationRecord
  extend T::Sig

  # Include default devise modules. Others available are:
  # :token_authenticatable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :confirmable
  after_create :create_api_key_object
  # TODO: Remove this when we can
  before_create :set_dummy_value_on_old_api_key
  # TODO: Rename to :api_key once api key field on users have been removed
  has_one :api_key_object, class_name: "ApiKey", dependent: :destroy

  sig { params(notification: T.untyped, args: T.untyped).void }
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # Overriding field on table
  # TODO: Remove this when we can
  sig { returns(T.nilable(String)) }
  def api_key
    api_key_object&.value
  end

  # Overriding field on table
  # TODO: Remove this when we can
  sig { returns(T.nilable(T::Boolean)) }
  def bulk_api
    api_key_object&.bulk
  end

  # Overriding field on table
  # TODO: Remove this when we can
  sig { returns(T.nilable(T::Boolean)) }
  def api_disabled
    api_key_object&.disabled
  end

  # Overriding field on table
  # TODO: Remove this when we can
  sig { returns(T.nilable(T::Boolean)) }
  def api_commercial
    api_key_object&.commercial
  end

  # Overriding field on table
  # TODO: Remove this when we can
  sig { returns(T.nilable(Integer)) }
  def api_daily_limit
    api_key_object&.daily_limit
  end

  private

  sig { void }
  def set_dummy_value_on_old_api_key
    self.api_key = ""
  end
end
