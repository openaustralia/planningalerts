# frozen_string_literal: true

Flipper::UI.configure do |config|
  config.descriptions_source = lambda do |_keys|
    # This should be a complete list of all features being currently used in the codebase
    {
      "switch_themes" => "Can switch to new in progress design for the site"
    }
  end

  # Defaults to false. Set to true to show feature descriptions on the list
  # page as well as the view page.
  config.show_feature_description_in_list = true
end

# Registers a group named admins - this can be used to easily add a feature for all
# admins
Flipper.register(:admins) do |actor, context|
  actor.respond_to?(:admin?) && actor.admin?
end
