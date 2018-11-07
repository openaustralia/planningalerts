# frozen_string_literal: true

class Rack::Throttle::Blocked < Rack::Throttle::Limiter
  def allowed?(_request)
    false
  end
end

class Rack::Throttle::Unlimited < Rack::Throttle::Limiter
  def allowed?(_request)
    true
  end
end

# A throttling strategy that is highly configurable per IP address.
# Different IP addresses can have different strategies
class ThrottleConfigurable < Rack::Throttle::Limiter
  attr_reader :strategies

  # strategies: {
  #   "hourly" => {
  #     100 => "default",
  #     200 => ["1.2.3.7", "1.2.3.8"],
  #   },
  #   "daily" => {
  #     60000 => "1.2.3.4"
  #   },
  #   "unlimited" => "1.2.3.5",
  #   "blocked" => "1.2.3.6",
  # }
  def initialize(app, options = {})
    super

    # Turn the more human readable lookup in the strategies option of blocks
    # of ip addresses with similar throttling into a lookup table of what to do
    # with each ip
    @strategies = {}
    options[:strategies].each do |strategy, value|
      case strategy
      when "hourly", "daily"
        value.each do |m, hosts|
          raise "Invalid max count used: #{m}" unless m.is_a?(Integer)
          add_hosts_to_strategies(hosts, strategy_factory(strategy, m))
        end
      when "unlimited", "blocked"
        add_hosts_to_strategies(value, strategy_factory(strategy))
      else
        raise "Invalid strategy name used: #{strategy}"
      end
    end
    raise "No default setting" if @strategies["default"].nil?
  end

  def strategy(ip)
    strategies[ip] || strategies["default"]
  end

  def allowed?(request)
    strategy(client_identifier(request)).allowed?(request)
  end

  private

  def strategy_factory(name, max = nil)
    case name
    when "blocked"
      Rack::Throttle::Blocked.new(nil)
    when "hourly"
      Rack::Throttle::Hourly.new(nil, options.merge(max: max))
    when "daily"
      Rack::Throttle::Daily.new(nil, options.merge(max: max))
    when "unlimited"
      Rack::Throttle::Unlimited.new(nil)
    end
  end

  def valid_ip?(ip)
    n = ip.split(".")
    (n.count == 4 && n.all? { |m| m.to_i >= 0 && m.to_i <= 255 }) || (ip == "default")
  end

  def add_hosts_to_strategies(hosts, strategy)
    hosts = [hosts] unless hosts.respond_to?(:each)
    hosts.each do |host|
      raise "Invalid ip address used: #{host}" unless valid_ip?(host)
      raise "ip address can not be used multiple times: #{host}" if @strategies.key?(host)
      @strategies[host] = strategy
    end
  end
end
