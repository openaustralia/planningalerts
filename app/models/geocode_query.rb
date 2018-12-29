# frozen_string_literal: true

class GeocodeQuery < ApplicationRecord
  has_many :geocode_results, dependent: :destroy
end
