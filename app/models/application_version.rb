# frozen_string_literal: true

class ApplicationVersion < ApplicationRecord
  belongs_to :application
  belongs_to :previous_version, class_name: "ApplicationVersion", optional: true

  delegate :authority, :council_reference, to: :application
end
