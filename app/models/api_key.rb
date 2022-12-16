# typed: strict
# frozen_string_literal: true

class ApiKey < ApplicationRecord
  extend T::Sig

  belongs_to :user
  has_many :daily_api_usages, dependent: :destroy

  before_create :set_value

  private

  sig { void }
  def set_value
    self.value = SecureRandom.base58(20)
  end
end
