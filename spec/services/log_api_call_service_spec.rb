# frozen_string_literal: true

require "spec_helper"

describe LogApiCallService do
  it "should log the api_key if it's valid" do
    user = create(:user, email: "foo@bar.com", password: "foofoo")
    LogApiCallService.call(
      api_key: user.api_key,
      ip_address: "1.2.3.4",
      query: "/applications.js?key=#{user.api_key}",
      user_agent: "Mozilla"
    )
    expect(ApiStatistic.first.user).to eq(user)
  end

  it "should not log the api key if it's not valid" do
    LogApiCallService.call(
      api_key: "1234",
      ip_address: "1.2.3.4",
      query: "/applications.js?key=1234",
      user_agent: "Mozilla"
    )
    expect(ApiStatistic.first.user).to be_nil
  end

  it "should not log the api key if it's not present" do
    LogApiCallService.call(
      api_key: nil,
      ip_address: "1.2.3.4",
      query: "/applications.js",
      user_agent: "Mozilla"
    )
    expect(ApiStatistic.first.user).to be_nil
  end
end
