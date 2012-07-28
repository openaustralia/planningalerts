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
      if strategy == "hourly" || strategy == "daily"
        value.each do |m, hosts|
          raise "Invalid max count used: #{m}" unless m.kind_of?(Integer)
          hosts = [hosts] unless hosts.respond_to?(:each)
          hosts.each do |host|
            raise "Invalid ip address used: #{host}" unless valid_ip?(host)
            raise "ip address can not be used multiple times: #{host}" if @ip_lookup.has_key?(host)
            @ip_lookup[host] = [strategy, m]
          end
        end
      elsif strategy == "unlimited" || strategy == "blocked"
        value = [value] unless value.respond_to?(:each)
        value.each do |host|
          raise "Invalid ip address used: #{host}" unless valid_ip?(host)
          raise "ip address can not be used multiple times: #{host}" if @ip_lookup.has_key?(host)
          @ip_lookup[host] = [strategy, nil]
        end
      else
        raise "Invalid strategy name used: #{strategy}"
      end
    end
    raise "No default setting" if @ip_lookup["default"].nil?
  end

  def allowed?(request)
    s = strategy(client_identifier(request))
    m = max(client_identifier(request))
    case(s)
    when "blocked"
      false
    when "hourly"
      t = Rack::Throttle::Hourly.new(nil, :cache => cache, :max => m)
      t.allowed?(request)
    when "daily"
      t = Rack::Throttle::Daily.new(nil, :cache => cache, :max => m)
      t.allowed?(request)      
    when "unlimited"
      true
    end
  end

  def valid_ip?(ip)
    n = ip.split(".")
    (n.count == 4 && n.all? {|m| m.to_i >= 0 && m.to_i <= 255}) || (ip == "default")
  end

  def strategy_config(ip)
    @ip_lookup[ip] || @ip_lookup["default"]
  end

  def strategy(ip)
    strategy_config(ip)[0]
  end

  def max(ip)
    strategy_config(ip)[1]
  end
end