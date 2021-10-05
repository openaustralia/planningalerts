# typed: true
# frozen_string_literal: true

module Admin
  class ApiUsagesController < Admin::ApplicationController
    extend T::Sig

    class IndexParams < T::Struct
      const :period, T.nilable(Integer)
    end

    sig { void }
    def index
      # typed_params = TypedParams[IndexParams].new.extract!(params)

      redirect_to(period: 30) and return if params[:period].nil?

      @period = T.let(params[:period].to_i, T.nilable(Integer))

      # TODO: Make this less ugly
      redis = Redis.new(Rails.configuration.redis)
      redis = Redis::Namespace.new(Rails.configuration.redis[:namespace], redis: redis)

      date_to = Time.zone.today
      # If period is 1 then we just want today's data roughly. If period is 2
      # we want today and yesterday
      date_from = date_to - (T.must(params[:period].to_i) - 1)
      @result = T.let(TopUsageApiUsersService.call(redis: redis, date_from: date_from,
                                                   date_to: date_to, number: 50),
                      T.nilable(T::Array[TopUsageApiUsersService::ApiKeyObjectRequests]))
    end
  end
end
