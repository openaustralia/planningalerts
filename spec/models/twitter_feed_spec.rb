# frozen_string_literal: true

require "spec_helper"

describe TwitterFeed do
  describe "#items" do
    it "should return the last 2 tweets" do
      items = VCR.use_cassette("twitter") do
        with_modified_env(
          TWITTER_CONSUMER_KEY: "1111",
          TWITTER_CONSUMER_SECRET: "2222",
          TWITTER_OAUTH_TOKEN: "3333",
          TWITTER_OAUTH_TOKEN_SECRET: "4444"
        ) { TwitterFeed.new("planningalerts").items }
      end
      expect(items.count).to eq 2
      expect(items[0].title).to eq "@wheelyweb definitely agree that things would be improved by showing a selection of trending applications in differ… https://t.co/z8XDZOz7kK"
      expect(items[0].date).to eq Time.zone.parse("2018-11-21 23:51:45 UTC")
      expect(items[0].link).to eq "https://twitter.com/planningalerts/status/1065392354255749120"
      expect(items[1].title).to eq "@wheelyweb the focus of PlanningAlerts is still very much on finding out what is happening locally near you. So, we… https://t.co/kXoTcuBAIy"
      expect(items[1].date).to eq Time.zone.parse("2018-11-21 23:46:57 UTC")
      expect(items[1].link).to eq "https://twitter.com/planningalerts/status/1065391145876828160"
    end
  end
end
