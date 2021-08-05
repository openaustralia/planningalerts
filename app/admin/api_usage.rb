# typed: false
# frozen_string_literal: true

ActiveAdmin.register_page "API usage" do
  content do
    # These URLs require you to login to our Kibana instance with a username and password.
    # So they're relatively safe to include here.
    para do
      link_to "View dashboard in Kibana", "https://d2ba5a791b81410f8d2365c8a6d59905.ap-southeast-2.aws.found.io:9243/app/kibana#/dashboard/8e1285f0-3582-11e9-8f74-c54feae3d9a2?_g=(refreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3Anow-1y%2Cmode%3Aquick%2Cto%3Anow))"
    end

    # TODO: Make this less ugly
    redis = Redis.new(Rails.configuration.redis)
    redis = Redis::Namespace.new(Rails.configuration.redis[:namespace], redis: redis)

    date_to = Date.today
    date_from = date_to - 30
    result = TopUsageAPIUsersService.call(redis: redis, date_from: date_from,
      date_to: date_to, number: 10)

    h2 "Top users of the API (by number of requests) over the last 30 days"

    table_for result do
      column(:name) { |usage| link_to usage.user.name, admin_user_path(usage.user) }
      column(:organisation) { |usage| link_to usage.user.organisation, admin_user_path(usage.user) }
      column(:email) { |usage| link_to usage.user.email, admin_user_path(usage.user) }
      column :requests
    end
  end
end
