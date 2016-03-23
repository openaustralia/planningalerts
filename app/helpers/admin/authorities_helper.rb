module Admin
  module AuthoritiesHelper
    def load_councillors_response_text(councillors)
      valid_councillors = councillors.select { |c| c.valid? }
      invalid_councillors = councillors.select { |c| c.invalid? }

      # TODO: DRY up duplication
      case
      when councillors.any? && valid_councillors.any? && invalid_councillors.any?
        "Successfully loaded #{pluralize valid_councillors.count, "councillor"}." + " " +
        "Skipped loading #{pluralize invalid_councillors.count, "councillor"}."
      when councillors.any? && valid_councillors.count == councillors.count
        "Successfully loaded #{pluralize valid_councillors.count, "councillor"}."
      when councillors.any? && invalid_councillors.count == councillors.count
        "Skipped loading #{pluralize invalid_councillors.count, "councillor"}."
      when councillors.empty?
        "Could not find any councillors in the data to load."
      end
    end
  end
end
