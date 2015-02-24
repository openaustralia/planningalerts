class ApiStatistic < ActiveRecord::Base
  belongs_to :api_key

  def self.log(request)
    # Lookup the api key if there is one
    key = ApiKey.find_by_key(request.query_parameters["key"])
    create!(:ip_address => request.remote_ip, :query => request.fullpath, :user_agent => request.headers["User-Agent"],:query_time => Time.now, api_key: key)
  end
end
