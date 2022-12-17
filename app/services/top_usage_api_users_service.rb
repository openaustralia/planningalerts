# typed: strict
# frozen_string_literal: true

class TopUsageApiUsersService
  extend T::Sig

  class ApiKeyRequests < T::Struct
    const :api_key, String
    const :requests, Integer
  end

  class ApiKeyObjectRequests < T::Struct
    const :api_key_object, ApiKey
    const :requests, Integer
  end

  sig { params(date_from: Date, date_to: Date, number: Integer).returns(T::Array[ApiKeyObjectRequests]) }
  def self.call(date_from:, date_to:, number:)
    new.call(date_from: date_from, date_to: date_to, number: number)
  end

  sig { params(date_from: Date, date_to: Date, number: Integer).returns(T::Array[ApiKeyObjectRequests]) }
  def call(date_from:, date_to:, number:)
    DailyApiUsage.where(date: date_from..date_to).group(:api_key_id).order("SUM(count) DESC").limit(number).sum(:count).map do |api_key_id, sum|
      ApiKeyObjectRequests.new(requests: sum, api_key_object: ApiKey.find(api_key_id))
    end
  end
end
