# typed: strict
# frozen_string_literal: true

class ApiKey < ApplicationRecord
  extend T::Sig

  belongs_to :user
  has_many :daily_api_usages, dependent: :destroy
  has_paper_trail

  validates :value, uniqueness: true

  before_create :set_value

  sig { params(value: String).returns(T.nilable(ApiKey)) }
  def self.find_valid(value)
    a = ApiKey.find_by(value:)
    return unless a&.active?

    a
  end

  sig { returns(Symbol) }
  def plan
    # This is a stop-gap measure until we implement a "proper" plan set-up
    if commercial
      # In reality this should be split out into "Standard" and "Premium"
      :commercial
    elsif community
      :community
    elsif expires_at
      # We're assuming that trial licenses always have an expiry
      :trial
    else
      # This shouldn't happen I think
      :other
    end
  end

  sig { returns(T::Boolean) }
  def active?
    !disabled && !expired?
  end

  sig { returns(T::Boolean) }
  def permanent?
    expires_at.nil?
  end

  sig { returns(T::Boolean) }
  def expired?
    e = expires_at
    !e.nil? && e <= Time.current
  end

  # By default we allow up to 1000 API requests per day per API key
  sig { returns(Integer) }
  def self.default_daily_limit
    1000
  end

  sig { returns(Integer) }
  def self.default_daily_limit_community
    1000
  end

  sig { returns(Integer) }
  def self.default_daily_limit_commercial
    5000
  end

  sig { returns(Integer) }
  def self.default_daily_limit_trial
    100
  end

  # TODO: Should this be longer (like 28 days)?
  sig { returns(Integer) }
  def self.default_trial_duration_days
    14
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
