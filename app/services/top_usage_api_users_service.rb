# typed: strict
# frozen_string_literal: true

class TopUsageApiUsersService
  extend T::Sig

  class ApiKeyCount < T::Struct
    const :api_key, ApiKey
    const :count, Integer
  end

  sig { params(date_from: Date, date_to: Date, number: Integer).returns(T::Array[ApiKeyCount]) }
  def self.call(date_from:, date_to:, number:)
    result = DailyApiUsage.top_usage_in_date_range(date_from: date_from, date_to: date_to, number: number)
    result.map do |api_key, sum|
      ApiKeyCount.new(count: sum, api_key: api_key)
    end
  end
end
