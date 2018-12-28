# frozen_string_literal: true

class GeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    GeocodeQuery.create!(query: address)
    GoogleGeocodeService.call(address)
  end

  private

  attr_reader :address
end
