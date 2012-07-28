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
  end

  def strategy_config2
    r = {}
    options[:strategies].each do |strategy, value|
      if strategy == "hourly" || strategy == "daily"
        value.each do |m, hosts|
          if hosts.respond_to?(:each)
            hosts.each do |host|
              r[host] = [strategy, m]
            end
          else
            r[hosts] = [strategy, m]
          end
        end
      elsif strategy == "unlimited" || strategy == "blocked"
        if value.respond_to?(:each)
          value.each do |host|
            r[host] = [strategy, nil]
          end
        else
          r[value] = [strategy, nil]
        end
      else
        raise "Unexpected value for strategy: #{strategy}"
      end
    end
    r
  end

  def strategy_config(ip)
    strategy_config2[ip] || strategy_config2["default"]
  end

  def strategy(ip)
    strategy_config(ip)[0]
  end

  def max(ip)
    strategy_config(ip)[1]
  end
end