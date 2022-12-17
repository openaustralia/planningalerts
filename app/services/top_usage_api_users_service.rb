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
    DailyApiUsage.where(date: date_from..date_to).group(:api_key_id).order("SUM(count) DESC").limit(number).sum(:count).map do |api_key_id, sum|
      ApiKeyCount.new(count: sum, api_key: ApiKey.find(api_key_id))
    end
  end
end
