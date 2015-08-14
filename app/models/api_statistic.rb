class ApiStatistic < ActiveRecord::Base
  belongs_to :user

  def self.log(request)
    # Lookup the api key if there is one
    user = User.find_by_api_key(request.query_parameters["key"]) unless request.query_parameters["key"].blank?
    create!(ip_address: request.remote_ip, query: request.fullpath, user_agent: request.headers["User-Agent"], query_time: Time.now, user: user)
  end
end
