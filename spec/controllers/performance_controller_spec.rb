# frozen_string_literal: true

require "spec_helper"

describe PerformanceController do
  before :each do
    request.env["HTTPS"] = "on"
  end

  describe "#comments" do
    before :each do
      Timecop.freeze(Time.utc(2016, 1, 5, 10))
    end

    after :each do
      Timecop.return
    end

    it { expect(get(:comments, format: :json)).to be_successful }

    context "when there are comments" do
      before do
        VCR.use_cassette("planningalerts", allow_playback_repeats: true) do
          create(:confirmed_comment, confirmed_at: 2.days.ago.to_date, email: "foo@example.com")
          create(:confirmed_comment, confirmed_at: 2.days.ago.to_date, email: "foo@example.com")
          create(:confirmed_comment, confirmed_at: 2.days.ago.to_date, email: "bar@example.com")
          create(:confirmed_comment, confirmed_at: 90.days.ago.to_date, email: "foo@example.com")
          create(:confirmed_comment, confirmed_at: 90.days.ago.to_date, email: "bar@example.com")
          create(:confirmed_comment, confirmed_at: 90.days.ago.to_date, email: "wiz@example.com")
        end
      end

      # FIXME: This example description seems wrong/is really confusing.
      it "returns an empty Array as json" do
        get(:comments, format: :json)

        expect(JSON.parse(response.body)).to include(
          "date" => "2016-01-03", "first_time_commenters" => 0, "returning_commenters" => 2
        )
        expect(JSON.parse(response.body)).to include(
          "date" => "2015-10-07", "first_time_commenters" => 3, "returning_commenters" => 0
        )
      end
    end
  end
end
