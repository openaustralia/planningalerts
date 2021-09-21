# typed: false
# frozen_string_literal: true

ActiveAdmin.register_page "API usage" do
  controller do
    def index
      redirect_to(period: 30) if params[:period].nil?
      @period = params[:period].to_i
    end
  end

  content do
    # These URLs require you to login to our Kibana instance with a username and password.
    # So they're relatively safe to include here.
    para do
      link_to "View dashboard in Kibana", "https://d2ba5a791b81410f8d2365c8a6d59905.ap-southeast-2.aws.found.io:9243/app/kibana#/dashboard/8e1285f0-3582-11e9-8f74-c54feae3d9a2?_g=(refreshInterval%3A(pause%3A!t%2Cvalue%3A0)%2Ctime%3A(from%3Anow-1y%2Cmode%3Aquick%2Cto%3Anow))"
    end

    # TODO: Make this less ugly
    redis = Redis.new(Rails.configuration.redis)
    redis = Redis::Namespace.new(Rails.configuration.redis[:namespace], redis: redis)

    period = @arbre_context.assigns[:period]
    date_to = Time.zone.today
    # If period is 1 then we just want today's data roughly. If period is 2
    # we want today and yesterday
    date_from = date_to - (period - 1)
    result = TopUsageApiUsersService.call(redis: redis, date_from: date_from,
                                          date_to: date_to, number: 50)

    h2 "Top 50 users of the API (by number of requests) over the last #{pluralize(period, 'day')}"

    para do
      "Note that these numbers are measured before any authorization is done. " \
      "So, for instance if an API key has been disabled but a user is still " \
      "making requests with that key, which are then getting denied, those " \
      "requests will still show up in the list here."
    end

    para do
      link_to_unless_current "last 30 days", period: 30
    end

    para do
      link_to_unless_current "last 7 days", period: 7
    end

    para do
      link_to_unless_current "last 1 day", period: 1
    end

    table_for result do
      column(:name) {         |usage| link_to usage.api_key_object.user.name,         admin_user_path(usage.api_key_object.user) }
      column(:organisation) { |usage| link_to usage.api_key_object.user.organisation, admin_user_path(usage.api_key_object.user) }
      column(:email) {        |usage| link_to usage.api_key_object.user.email,        admin_user_path(usage.api_key_object.user) }
      column(:disabled) {     |usage| usage.api_key_object.disabled }
      column(:commercial) {   |usage| usage.api_key_object.commercial }
      column(:daily_limit) {  |usage| usage.api_key_object.daily_limit }
      column :requests
    end
  end
end
