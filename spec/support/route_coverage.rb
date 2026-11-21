# frozen_string_literal: true

# Fails a full spec run when:
# - a GET route has no page check (have_site_layout,
#   have_no_broken_internal_links or have_no_missing_assets) run against it,
#   unless it is listed in EXCEPTIONS with a reason
# - a routed controller action is never requested by any passing example,
#   whatever its verb or format, unless it is listed in ACTION_EXCEPTIONS
# Also fails when an exception is out of date, so the lists stay honest.
module RouteCoverage
  # Keys are "controller#action" as Rails routes them
  ACTION_EXCEPTIONS = {
    "admin/comments#confirm" => "routed, but the controller has no confirm action",
    "alerts/registrations#cancel" => "unused Devise route (#2163)",
    "alerts/registrations#destroy" => "unused Devise route (#2163)",
    "alerts/registrations#edit" => "unused Devise route (#2163)",
    "alerts/registrations#update" => "unused Devise route (#2163)",
    "alerts/sessions#destroy" => "unused Devise route (#2163)",
    "users/registrations#cancel" => "unused Devise route (#2163)",
    "api_keys/non_commercials#new" => "pending until #2352",
    "api_keys/paid#new" => "pending until #2352",
    "api_keys/non_commercials#create" => "routed, but no create action exists (#2352)",
    "api_keys/paid#create" => "routed, but no create action exists (#2352)"
  }.freeze

  # Keys are "VERB path" as Rails declares them (see `bin/rails routes`)
  EXCEPTIONS = {
    "GET|POST /health_check(/:checks)(.:format)" => "load balancer health check, plain text",
    "ANY /(*path)" => "404s everything else on the API hostnames, covered by api_hostnames_spec",
    "ANY /admin/flipper" => "Flipper's own UI",
    "ANY /admin/split" => "Split's own dashboard",
    "ANY /admin/jobs" => "Sidekiq's own dashboard",
    "GET /admin/users/export_confirmed_emails(.:format)" => "text file download, covered by admin/users_spec",
    "GET /admin/homes(.:format)" => "same page as /admin, which is tested",
    "GET /users/confirmation(.:format)" => "redirects once the email is confirmed, covered by user_sign_up_spec",
    "GET /users/unlock(.:format)" => "redirects once the account is unlocked",
    "GET /users/cancel(.:format)" => "unused Devise route (#2163)",
    "GET /profile/alerts/users/cancel(.:format)" => "unused Devise route (#2163)",
    "GET /profile/alerts/users/edit(.:format)" => "unused Devise route (#2163)",
    "GET /authorities/:id/boundary(.:format)" => "JSON only",
    "GET /authorities/:authority_id/applications/per_week(.:format)" => "JSON only",
    "GET /authorities/:authority_id/comments/per_week(.:format)" => "JSON only",
    "GET /altcha/challenge(.:format)" => "JSON only, covered by altcha_challenges_controller_spec",
    "GET /whatismyip(.:format)" => "plain text, covered by whatismyip_controller_spec",
    "GET /api_keys/non_commercial/new(.:format)" => "pending until #2352",
    "GET /api_keys/paid/new(.:format)" => "pending until #2352"
  }.freeze

  @visited = Set.new
  @this_example = Set.new
  @requested = Set.new
  @this_example_actions = Set.new
  # Feature specs with JavaScript serve requests from another thread
  @lock = Mutex.new

  class << self
    attr_reader :visited, :requested

    # Only count pages and actions from examples that passed, so a failing or
    # pending example doesn't count as covering them
    def finish_example(example)
      @lock.synchronize do
        unless example.exception || example.pending?
          @visited.merge(@this_example)
          @requested.merge(@this_example_actions)
        end
        @this_example = Set.new
        @this_example_actions = Set.new
      end
    end

    def record_action(controller_class_name, action)
      @lock.synchronize do
        @this_example_actions << "#{controller_class_name.underscore.delete_suffix('_controller')}##{action}"
      end
    end

    # "controller#action" for every route that leads to one of our
    # controllers, apart from Rails' own and redirects
    def routed_actions
      Rails.application.routes.routes.filter_map do |route|
        controller, action = route.defaults.values_at(:controller, :action)
        next if controller.nil? || action.nil? || framework?(route) || redirect?(route)

        "#{controller}##{action}"
      end.uniq
    end

    def key(route)
      "#{route.verb.presence || 'ANY'} #{route.path.spec}"
    end

    # Note the route of a request spec's response or a feature spec's page.
    # Hand-built HTML, as in the matchers' own spec, has no route.
    def record(actual)
      method, path = if actual.respond_to?(:request)
                       [actual.request.request_method, actual.request.path]
                     elsif actual.respond_to?(:current_url)
                       ["GET", URI(actual.current_url).path]
                     end
      return unless path

      route = PageMatchers.route_for(method, path)
      @this_example << key(route) if route
    end

    # Routes a page check should cover: everything reachable by GET apart
    # from Rails' own routes, redirects and API routes that need a format
    def page_routes
      Rails.application.routes.routes.reject do |route|
        verb = route.verb.presence
        verb&.split("|")&.exclude?("GET") ||
          framework?(route) || redirect?(route) || format_only?(route)
      end
    end

    def framework?(route)
      path = route.path.spec.to_s
      path.start_with?("/rails/", "/_system_test_entrypoint", "/assets", "/cable")
    end

    # Redirects aren't pages; redirects_spec covers the important ones
    def redirect?(route)
      app = route.app
      app = app.app if app.is_a?(ActionDispatch::Routing::Mapper::Constraints)
      app.is_a?(ActionDispatch::Routing::Redirect)
    end

    # API endpoints and the 404s that stop them leaking onto the website,
    # all covered by api_controller_spec and api_hostnames_spec
    def format_only?(route)
      route.path.spec.to_s.end_with?(".:format") && !route.path.spec.to_s.end_with?("(.:format)")
    end

    def problems
      expected = page_routes.map { |route| key(route) }.uniq
      untested = expected - visited.to_a - EXCEPTIONS.keys
      now_tested = EXCEPTIONS.keys & visited.to_a
      unknown = EXCEPTIONS.keys - expected
      [
        ["Routes with no page check (add one, or an exception in spec/support/route_coverage.rb):", untested],
        ["Exceptions that now have a page check, so remove them:", now_tested],
        ["Exceptions that no longer match a route:", unknown]
      ].reject { |_heading, keys| keys.empty? } + action_problems
    end

    def action_problems
      expected = routed_actions
      [
        ["Controller actions no spec requests (add one, or an action exception):",
         expected - requested.to_a - ACTION_EXCEPTIONS.keys],
        ["Action exceptions that are now requested, so remove them:", ACTION_EXCEPTIONS.keys & requested.to_a],
        ["Action exceptions that no longer match a route:", ACTION_EXCEPTIONS.keys - expected]
      ].reject { |_heading, keys| keys.empty? }
    end

    # Only a full, unfiltered run visits every page
    def full_run?
      config = RSpec.configuration
      all_specs = Dir[Rails.root.join("spec/**/*_spec.rb")].map { |f| File.expand_path(f) }.sort
      config.files_to_run.map { |f| File.expand_path(f) }.sort == all_specs &&
        config.filter_manager.inclusions.empty?
    end
  end
end

ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*, payload|
  RouteCoverage.record_action(payload[:controller], payload[:action])
end

RSpec.configure do |config|
  config.after { |example| RouteCoverage.finish_example(example) }

  config.after(:suite) do
    next unless RouteCoverage.full_run?

    problems = RouteCoverage.problems
    next if problems.empty?

    raise problems.map { |heading, keys| "#{heading}\n  #{keys.sort.join("\n  ")}" }.join("\n\n")
  end
end
