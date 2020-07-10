# typed: true
# frozen_string_literal: true

class AuthoritiesController < ApplicationController
  class IndexParams < T::Struct
    const :order, T.nilable(String)
  end

  def index
    typed_params = TypedParams[IndexParams].new.extract!(params)
    @authority_count = Authority.active.count
    @percentage_population_covered_by_all_active_authorities = Authority.percentage_population_covered_by_all_active_authorities.to_i
    @authorities = Authority.enabled
    @authorities = @authorities.order(population_2017: :desc) if typed_params.order == "population"
    @authorities = @authorities.order(:state, :full_name)
  end

  class ShowParams < T::Struct
    const :id, String
  end

  def show
    typed_params = TypedParams[ShowParams].new.extract!(params)
    # TODO: Use something like the friendly_id gem instead
    @authority = Authority.find_short_name_encoded!(typed_params.id)
  end

  class UnderTheHoodParams < T::Struct
    const :authority_id, String
  end

  def under_the_hood
    typed_params = TypedParams[UnderTheHoodParams].new.extract!(params)
    @authority = Authority.find_short_name_encoded!(typed_params.authority_id)
  end
end
