# frozen_string_literal: true

require "spec_helper"

describe TwitterFeed do
  describe "#items" do
    let(:silent_logger) do
      logger = Logger.new($stdout)
      allow(logger).to receive(:warn)
      allow(logger).to receive(:error)
      logger
    end

    context "with no twitter credentials" do
      it "returns nothing" do
        expect(described_class.new("planningalerts", silent_logger).items).to be_empty
      end

      it "logs a warning" do
        logger = Logger.new($stdout)
        allow(logger).to receive(:warn)
        described_class.new("planningalerts", logger).items
        expect(logger).to have_received(:warn).with("No twitter API credentials set")
      end
    end

    context "with valid twitter credentials" do
      around do |test|
        with_modified_env(
          TWITTER_CONSUMER_KEY: "1111",
          TWITTER_CONSUMER_SECRET: "2222",
          TWITTER_OAUTH_TOKEN: "3333",
          TWITTER_OAUTH_TOKEN_SECRET: "4444"
        ) do
          test.run
        end
      end

      context "when a valid twitter user" do
        let(:twitter_user) { "planningalerts" }

        it "returns the last 2 tweets" do
          items = VCR.use_cassette("twitter") do
            described_class.new(twitter_user, Logger.new($stdout)).items
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

      context "when an invalid twitter user" do
        let(:twitter_user) { "abc768a" }

        it "returns nothing" do
          items = VCR.use_cassette("twitter") do
            described_class.new(twitter_user, silent_logger).items
          end
          expect(items).to be_empty
        end

        it "logs an error" do
          logger = Logger.new($stdout)
          allow(logger).to receive(:error)
          VCR.use_cassette("twitter") do
            described_class.new(twitter_user, logger).items
          end
          expect(logger).to have_received(:error).with("while accessing twitter API: Sorry, that page does not exist.")
        end
      end
    end
  end
end
