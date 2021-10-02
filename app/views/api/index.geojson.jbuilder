# typed: false
# frozen_string_literal: true

json.type "FeatureCollection"
json.features @applications do |application|
  json.partial! "application", application: application
end
