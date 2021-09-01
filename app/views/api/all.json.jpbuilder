# typed: strict
# frozen_string_literal: true

json.application_count @applications.count
json.max_id @max_id
json.applications @applications do |application|
  json.partial! "application.json", application: application
end
