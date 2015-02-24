require 'spec_helper'

describe ApiStatistic do
  it "should log the api_key if it's valid" do
    user = User.create!(email: "foo@bar.com", password: "foofoo")
    request = mock(query_parameters: {"key" => user.api_key}, remote_ip: "1.2.3.4", fullpath: "/applications.js?key=#{user.api_key}", headers: {"User-Agent" => "Mozilla"})
    ApiStatistic.log(request)
    ApiStatistic.first.user.should == user
  end

  it "should not log the api key if it's not valid" do
    user = User.create!(email: "foo@bar.com", password: "foofoo")
    request = mock(query_parameters: {"key" => "1234"}, remote_ip: "1.2.3.4", fullpath: "/applications.js?key=1234", headers: {"User-Agent" => "Mozilla"})
    ApiStatistic.log(request)
    ApiStatistic.first.user.should be_nil
  end

  it "should not log the api key if it's not present" do
    user = User.create!(email: "foo@bar.com", password: "foofoo")
    request = mock(query_parameters: {}, remote_ip: "1.2.3.4", fullpath: "/applications.js", headers: {"User-Agent" => "Mozilla"})
    ApiStatistic.log(request)
    ApiStatistic.first.user.should be_nil
  end
end
