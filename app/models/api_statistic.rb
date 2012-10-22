class ApiStatistic < ActiveRecord::Base
  def self.log(request)
    create!(:ip_address => ip_address(request), :query => request.fullpath, :user_agent => request.headers["User-Agent"],:query_time => Time.now)
  end

  # Get the source ip address. Also handle the case where the request is coming from an http proxy or load balancer.
  def self.ip_address(request)
    request.headers["X-Forwarded-For"] || request.remote_ip
  end
end
