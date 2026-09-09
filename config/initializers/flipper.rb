# frozen_string_literal: true

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::Redis.new(Redis.new(url: Rails.configuration.x.flipper_redis_url)) }
end

Flipper::UI.configure do |config|
  config.descriptions_source = lambda do |_keys|
    # This should be a complete list of all features being currently used in the codebase
    {
      "disable_streetview_in_app" => "Disable Google streetview in the main application. Do this to save money",
      "extra_options_on_address_search" => "Add extra options to filter by time/space when searching address",
      "show_authority_map" => "Show boundary of authority on a map",
      # Very important to note that switching on maintance_mode ** is not enough **.
      # You must also disable writes to the database by creating a database user with read-only privileges and using that
      "maintenance_mode" => "Put a banner across the site and give helpful message to the user if trying to write to the database",
      "full_text_search" => "Allow searching for all applications containing the word 'tree', for example",
      "view_application_versions" => "Can view the update history of an application",
      "request_api_keys" => "Allow a new experimental flow for requesting API keys",
      "provide_whatismyip" => "Serve /whatismyip, a trust-boundary check for Cloudflare/ALB proxying",
      "altcha" => "Show the ALTCHA proof-of-work check on the public forms (sign up, password reset, " \
                  "resend confirmation, account activation) and check the answer. On the contact form " \
                  "this also decides who sees ALTCHA rather than reCAPTCHA, so a percentage gate here " \
                  "runs the two side by side. Roll out with percentage_of_actors, never " \
                  "percentage_of_time: a form is rendered on one request and checked on another, and " \
                  "a gate that answers differently each time would reject people whose form was " \
                  "rendered without a widget. The admins group is no use here, because every " \
                  "protected form is one only logged-out people ever see",
      "altcha_enforce" => "Turn a failed ALTCHA check into a rejection. With this off every form is " \
                          "monitor only: the widget is shown, the answer is checked, the outcome is " \
                          "counted in Sentry, and the form goes through anyway. Leave it off until the " \
                          "Sentry numbers say what enforcing would cost, since enforcing turns away " \
                          "everyone without JavaScript"
    }
  end

  # Give a readable description when we add specific users (instead of "User;1234" for example)
  config.actor_names_source = ->(actor_ids) {
    db_ids = actor_ids.select{|id| id.split(';')[0] == "User"}.map{|id| id.split(';')[1] }
    users = User.where(id: db_ids)
    users.map{|u| ["User;#{u.id}", u.name_with_fallback]}.to_h
  }

  # Defaults to false. Set to true to show feature descriptions on the list
  # page as well as the view page.
  config.show_feature_description_in_list = true
end

# Registers a group named admins - this can be used to easily add a feature for all
# admins
#
# Not every actor is a User. A logged-out person on one of the ALTCHA-protected
# forms is a Visitor (see app/models/visitor.rb), which has a flipper_id so that
# a percentage gate has something stable to hash, but no roles. Checking that
# the actor can answer at all keeps this group from raising on anyone who isn't
# signed in.
Flipper.register(:admins) do |actor, context|
  actor.respond_to?(:has_role?) && actor.has_role?(:admin)
end
