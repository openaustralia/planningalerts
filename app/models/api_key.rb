# typed: strict
# frozen_string_literal: true

class ApiKey < ApplicationRecord
  extend T::Sig

  belongs_to :user
  has_many :daily_api_usages, dependent: :destroy

  validates :value, uniqueness: true

  before_create :set_value

  sig { params(value: String).returns(T.nilable(ApiKey)) }
  def self.find_valid(value)
    ApiKey.find_by(value:, disabled: false)
  end

  # By default we allow up to 1000 API requests per day per API key
  sig { returns(Integer) }
  def self.default_daily_limit
    1000
  end

  # Returns the daily limit for a given API key value. If no daily limit
  # is set will return the default daily limit. Also, if an invalid key is given it
  # will return the default daily limit as well.
  sig { params(value: String).returns(Integer) }
  def self.daily_limit_with_default(value)
    ApiKey.find_valid(value)&.daily_limit || ApiKey.default_daily_limit
  end

  private

  # TODO: Retry if api key value is not unique
  sig { void }
  def set_value
    self.value = SecureRandom.base58(20)
  end
end
