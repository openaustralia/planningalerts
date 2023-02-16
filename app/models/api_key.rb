# typed: strict
# frozen_string_literal: true

class ApiKey < ApplicationRecord
  extend T::Sig

  belongs_to :user
  has_many :daily_api_usages, dependent: :destroy

  before_create :set_value

  # TODO: Ensure that value is unique
  # There should be a validation here and a unique index in the schema

  sig { params(value: String).returns(T.nilable(ApiKey)) }
  def self.find_valid(value)
    ApiKey.find_by(value:, disabled: false)
  end

  private

  sig { void }
  def set_value
    self.value = SecureRandom.base58(20)
  end
end
