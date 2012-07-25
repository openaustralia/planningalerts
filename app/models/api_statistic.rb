class ApiStatistic < ActiveRecord::Base
  def self.log(request)
    create!(:ip_address => request.remote_ip, :query => request.fullpath, :query_time => Time.now)
  end
end
