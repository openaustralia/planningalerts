cookie_adapter = Split::Persistence::CookieAdapter
redis_adapter = Split::Persistence::RedisAdapter.with_config(
    lookup_by: -> (context) { context.send(:current_user).try(:id) },
    expire_seconds: 2592000)

Split.configure do |config|
  config.redis = Rails.configuration.x.split_redis_url

  config.persistence = Split::Persistence::DualAdapter.with_config(
      logged_in: -> (context) { !context.send(:current_user).try(:id).nil? },
      logged_in_adapter: redis_adapter,
      logged_out_adapter: cookie_adapter)
  config.persistence_cookie_length = 2592000 # 30 days
end
