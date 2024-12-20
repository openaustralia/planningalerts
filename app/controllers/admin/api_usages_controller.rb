# typed: strict
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

      params_period = T.cast(params[:period], T.nilable(T.any(String, Numeric)))

      redirect_to(period: 30) and return if params_period.nil?

      @period = T.let(params_period.to_i, T.nilable(Integer))

      date_to = Time.zone.today
      # If period is 1 then we just want today's data roughly. If period is 2
      # we want today and yesterday
      date_from = date_to - (params_period.to_i - 1)
      result = DailyApiUsage.top_average_usage_in_date_range(date_from:, date_to:, number: 50)
      @result = T.let(result, T.nilable(T::Array[{ api_key: ApiKey, mean: Float }]))
    end
  end
end
