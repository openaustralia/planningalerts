# frozen_string_literal: true

class GeocodeService < ApplicationService
  def initialize(address)
    @address = address
  end

  def call
    GoogleGeocodeService.call(address)
  end

  private

  attr_reader :address
end
