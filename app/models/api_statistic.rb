class ApiStatistic < ActiveRecord::Base
  def self.log(request)
    create!(:ip_address => request.remote_ip, :query => request.fullpath, :user_agent => request.headers["User-Agent"],:query_time => Time.now)
  end
end
