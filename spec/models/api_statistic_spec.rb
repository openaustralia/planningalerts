require 'spec_helper'

describe ApiStatistic do
  it "should log the api_key if it's valid" do
    key = ApiKey.create
    request = mock(query_parameters: {"key" => key.key}, remote_ip: "1.2.3.4", fullpath: "/applications.js?key=#{key.key}", headers: {"User-Agent" => "Mozilla"})
    ApiStatistic.log(request)
    ApiStatistic.first.api_key.should == key
  end

  it "should not log the api key if it's not valid" do
    key = ApiKey.create
    request = mock(query_parameters: {"key" => "1234"}, remote_ip: "1.2.3.4", fullpath: "/applications.js?key=1234", headers: {"User-Agent" => "Mozilla"})
    ApiStatistic.log(request)
    ApiStatistic.first.api_key.should be_nil
  end

  it "should not log the api key if it's not present" do
    key = ApiKey.create
    request = mock(query_parameters: {}, remote_ip: "1.2.3.4", fullpath: "/applications.js", headers: {"User-Agent" => "Mozilla"})
    ApiStatistic.log(request)
    ApiStatistic.first.api_key.should be_nil
  end
end
