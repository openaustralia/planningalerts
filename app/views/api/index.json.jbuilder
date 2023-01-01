# typed: strict
# frozen_string_literal: true

json.array! @applications do |application|
  json.partial! partial: "application", formats: :json, locals: { application: }
end
