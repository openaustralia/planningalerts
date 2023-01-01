# typed: strict
# frozen_string_literal: true

json.application_count @applications.count
json.page_count @applications.total_pages
json.applications @applications do |application|
  json.partial! partial: "application", formats: :json, locals: { application: }
end
