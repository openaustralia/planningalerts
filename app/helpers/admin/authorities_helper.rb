module Admin
  module AuthoritiesHelper
    def load_councillors_response_text(councillors)
      valid_councillors = councillors.select(&:valid?)
      invalid_councillors = councillors.select(&:invalid?)
      error_messages = invalid_councillors.map do |c|
        "#{c.name} (#{c.errors.full_messages.to_sentence})"
      end.to_sentence

      # TODO: DRY up duplication
      if councillors.any? && valid_councillors.any? && invalid_councillors.any?
        "Successfully loaded/updated #{pluralize valid_councillors.count, 'councillor'}." + " " \
          "Skipped loading #{pluralize invalid_councillors.count, 'councillor'}. #{error_messages}."
      elsif councillors.any? && valid_councillors.count == councillors.count
        "Successfully loaded/updated #{pluralize valid_councillors.count, 'councillor'}."
      elsif councillors.any? && invalid_councillors.count == councillors.count
        "Skipped loading #{pluralize invalid_councillors.count, 'councillor'}. #{error_messages}."
      elsif councillors.empty?
        "Could not find any councillors in the data to load."
      end
    end
  end
end
