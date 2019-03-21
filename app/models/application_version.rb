# frozen_string_literal: true

class ApplicationVersion < ApplicationRecord
  belongs_to :application
  belongs_to :previous_version, class_name: "ApplicationVersion", optional: true

  validates :current, uniqueness: { scope: :application_id }, if: :current

  delegate :authority, :council_reference, to: :application

  # TODO: factor out common location accessor between Application and Alert
  def location
    Location.new(lat: lat, lng: lng) if lat && lng
  end
end
