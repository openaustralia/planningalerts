class Rack::Throttle::Blocked < Rack::Throttle::Limiter
  def allowed?(request)
    false
  end
end

class Rack::Throttle::Unlimited < Rack::Throttle::Limiter
  def allowed?(request)
    true
  end
end

# A throttling strategy that is highly configurable per IP address.
# Different IP addresses can have different strategies
class ThrottleConfigurable < Rack::Throttle::Limiter
  #:strategies => {
  #  "hourly" => {
  #    100 => "default",
  #    200 => ["1.2.3.7", "1.2.3.8"],
  #  },
  #  "daily" => {
  #    60000 => "1.2.3.4"
  #  },
  #  "unlimited" => "1.2.3.5",
  #  "blocked" => "1.2.3.6",
  #}
  def initialize(app, options = {})
    super

    # Turn the more human readable lookup in the strategies option of blocks
    # of ip addresses with similar throttling into a lookup table of what to do
    # with each ip
    @ip_lookup = {}
    options[:strategies].each do |strategy, value|
      case strategy
      when "hourly", "daily"
        value.each do |m, hosts|
          raise "Invalid max count used: #{m}" unless m.kind_of?(Integer)
          add_hosts_to_ip_lookup(hosts, strategy_factory(strategy, m))
        end
      when "unlimited", "blocked"
        add_hosts_to_ip_lookup(value, strategy_factory(strategy, nil))
      else
        raise "Invalid strategy name used: #{strategy}"
      end
    end
    raise "No default setting" if @ip_lookup["default"].nil?
  end

  def strategy_factory(name, max)
    case(name)
    when "blocked"
      Rack::Throttle::Blocked.new(nil)
    when "hourly"
      Rack::Throttle::Hourly.new(nil, :cache => cache, :max => max)
    when "daily"
      Rack::Throttle::Daily.new(nil, :cache => cache, :max => max)
    when "unlimited"
      Rack::Throttle::Unlimited.new(nil)
    end
  end

  def strategy_object(ip)
    @ip_lookup[ip] || @ip_lookup["default"]
  end

  def allowed?(request)
    t = strategy_object(client_identifier(request))
    t.allowed?(request)
  end

  def valid_ip?(ip)
    n = ip.split(".")
    (n.count == 4 && n.all? {|m| m.to_i >= 0 && m.to_i <= 255}) || (ip == "default")
  end

  private

  def add_hosts_to_ip_lookup(hosts, s)
    hosts = [hosts] unless hosts.respond_to?(:each)
    hosts.each do |host|
      raise "Invalid ip address used: #{host}" unless valid_ip?(host)
      raise "ip address can not be used multiple times: #{host}" if @ip_lookup.has_key?(host)
      @ip_lookup[host] = s
    end
  end
end