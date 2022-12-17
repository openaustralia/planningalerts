# typed: strict
# frozen_string_literal: true

class DailyApiUsage < ApplicationRecord
  extend T::Sig

  belongs_to :api_key

  sig { params(date_from: Date, date_to: Date, number: Integer).returns(T::Hash[ApiKey, Integer]) }
  def self.top_usage_in_date_range(date_from:, date_to:, number:)
    count = where(date: date_from..date_to).group(:api_key_id).order("SUM(count) DESC").limit(number).sum(:count)
    count.transform_keys { |id| ApiKey.find(id) }
  end
end
