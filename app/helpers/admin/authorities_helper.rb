# typed: true
# frozen_string_literal: true

module Admin
  module AuthoritiesHelper
    def load_councillors_response_text(councillors)
      valid_councillors = councillors.select(&:valid?)
      invalid_councillors = councillors.select(&:invalid?)
      error_messages = invalid_councillors.map do |c|
        "#{c.name} (#{c.errors.full_messages.to_sentence})"
      end.to_sentence

      return "Could not find any councillors in the data to load." if councillors.empty?

      valid_message = "Successfully loaded/updated #{pluralize valid_councillors.count, 'councillor'}. "
      invalid_message = "Skipped loading #{pluralize invalid_councillors.count, 'councillor'}. #{error_messages}."
      text = ""
      text += valid_message if valid_councillors.any?
      text += invalid_message if invalid_councillors.any?
      text.strip
    end
  end
end
