# frozen_string_literal: true

require "spec_helper"

describe ApplicationsHelper do
  let(:authority) { mock_model(Authority, full_name: "An authority", short_name: "Blue Mountains") }
  let(:application) do
    mock_model(
      Application,
      map_url: "http://a.map.url",
      description: "A planning application",
      council_reference: "A1",
      authority:,
      info_url: "http://info.url",
      on_notice_from: nil,
      on_notice_to: nil
    )
  end

  describe "display_description_with_address" do
    before do
      allow(application).to receive(:address).and_return("Foo Road, NSW")
    end

    context "when the application has a short description" do
      before do
        allow(application).to receive(:description).and_return("Build something")
      end

      it {
        expect(helper.display_description_with_address(application))
          .to eq "“Build something” at Foo Road, NSW"
      }

      it { expect(helper.display_description_with_address(application)).not_to be html_safe? }
    end

    context "when the application has a description longer than 30 characters" do
      before do
        allow(application).to receive(:description).and_return("Build something really really big")
      end

      it "trucates the description" do
        expect(helper.display_description_with_address(application))
          .to eq "“Build something really...” at Foo Road, NSW"
      end
    end

    context "when the application has a description with special characters" do
      before do
        allow(application).to receive(:description).and_return("Alertations & additions")
      end

      it "does not escape them" do
        expect(helper.display_description_with_address(application))
          .to eq "“Alertations & additions” at Foo Road, NSW"
      end
    end
  end

  describe "on_notice_text" do
    before do
      allow(application).to receive_messages(address: "foo", lat: 1.0, lng: 2.0, location: Location.new(lat: 1.0, lng: 2.0), date_received: nil, date_scraped: Time.zone.now)
    end

    it "says when the application is on notice (and hasn't started yet)" do
      allow(application).to receive_messages(on_notice_from: Time.zone.today + 2.days, on_notice_to: Time.zone.today + 16.days)
      expect(helper.on_notice_text(application)).to eq(
        "The period to have your comment officially considered by the planning authority <strong>starts in 2 days</strong> and finishes 14 days later."
      )
    end

    describe "period started today" do
      it "says when the application is on notice" do
        allow(application).to receive_messages(on_notice_from: Time.zone.today, on_notice_to: Time.zone.today + 14.days)
        expect(helper.on_notice_text(application)).to eq(
          "<strong>You have 14 days left</strong> to have your comment officially considered by the planning authority. The period for comment started today."
        )
      end
    end

    describe "period started a day ago" do
      it "says when the application is on notice" do
        allow(application).to receive_messages(on_notice_from: Time.zone.today - 1.day, on_notice_to: Time.zone.today + 13.days)
        expect(helper.on_notice_text(application)).to eq(
          "<strong>You have 13 days left</strong> to have your comment officially considered by the planning authority. The period for comment started yesterday."
        )
      end
    end

    describe "period is in progress" do
      before do
        allow(application).to receive_messages(on_notice_from: Time.zone.today - 2.days, on_notice_to: Time.zone.today + 12.days)
      end

      it "says when the application is on notice" do
        expect(helper.on_notice_text(application)).to eq(
          "<strong>You have 12 days left</strong> to have your comment officially considered by the planning authority. The period for comment started 2 days ago."
        )
      end

      it "onlies say when on notice to if there is no on notice from information" do
        allow(application).to receive(:on_notice_from).and_return(nil)
        expect(helper.on_notice_text(application)).to eq(
          "<strong>You have 12 days left</strong> to have your comment officially considered by the planning authority."
        )
      end
    end

    describe "period is finishing today" do
      it "says when the application is on notice" do
        allow(application).to receive_messages(on_notice_from: Time.zone.today - 14.days, on_notice_to: Time.zone.today)
        expect(helper.on_notice_text(application)).to eq(
          "<strong>Today is the last day</strong> to have your comment officially considered by the planning authority. The period for comment started 14 days ago."
        )
      end
    end

    describe "period is finished" do
      before do
        allow(application).to receive_messages(on_notice_from: Time.zone.today - 16.days, on_notice_to: Time.zone.today - 2.days)
      end

      it "says when the application is on notice" do
        expect(helper.on_notice_text(application)).to eq(
          "You&#39;re too late! The period for officially commenting on this application <strong>finished 2 days ago</strong>. It lasted for 14 days. If you chose to comment now, your comment will still be displayed here and be sent to the planning authority but it will <strong>not be officially considered</strong> by the planning authority."
        )
      end

      it "onlies say when on notice to if there is no on notice from information" do
        allow(application).to receive(:on_notice_from).and_return(nil)
        expect(helper.on_notice_text(application)).to eq(
          "You&#39;re too late! The period for officially commenting on this application <strong>finished 2 days ago</strong>. If you chose to comment now, your comment will still be displayed here and be sent to the planning authority but it will <strong>not be officially considered</strong> by the planning authority."
        )
      end
    end

    describe "static maps" do
      before do
        allow(application).to receive(:address).and_return("Foo Road, NSW")
        allow(Rails.application.credentials).to receive(:dig).with(:google_maps, :api_key).and_return("abc")
        allow(Rails.application.credentials).to receive(:dig).with(:google_maps, :cryptographic_key).and_return("123456789012345678901234567=")
      end

      it "generates a static google map api image" do
        expect(helper.google_static_map(application, size: "350x200", zoom: 16)).to eq(
          "<img alt=\"Map of Foo Road, NSW\" src=\"https://maps.googleapis.com/maps/api/staticmap?key=abc&amp;maptype=roadmap&amp;markers=color%3Ared%7C1.0%2C2.0&amp;size=350x200&amp;zoom=16&amp;signature=BDMqLaSPiNHLtaxJtbj3n8YM0dg=\" width=\"350\" height=\"200\" />"
        )
      end
    end

    describe "static streetview" do
      before do
        allow(application).to receive(:address).and_return("Foo Road, NSW")
        Rails.application.credentials.dig(:google_maps, :api_key)
        allow(Rails.application.credentials).to receive(:dig).with(:google_maps, :api_key).and_return("abc")
        allow(Rails.application.credentials).to receive(:dig).with(:google_maps, :cryptographic_key).and_return("123456789012345678901234567=")
      end

      it "generates a static google streetview image" do
        expect(helper.google_static_streetview(application, size: "350x200", fov: 90)).to eq(
          "<img alt=\"Streetview of Foo Road, NSW\" src=\"https://maps.googleapis.com/maps/api/streetview?fov=90&amp;key=abc&amp;location=1.0%2C2.0&amp;size=350x200&amp;signature=jVq9tBwGacE2vi01iJhpwi-VTls=\" width=\"350\" height=\"200\" />"
        )
      end
    end
  end

  describe "#heading_in_words" do
    describe "north" do
      it { expect(helper.heading_in_words(0.0)).to eq "north" }
      it { expect(helper.heading_in_words(-22.5)).to eq "north" }
      it { expect(helper.heading_in_words(22.4)).to eq "north" }
    end

    describe "northeast" do
      it { expect(helper.heading_in_words(22.5)).to eq "northeast" }
      it { expect(helper.heading_in_words(45.0)).to eq "northeast" }
      it { expect(helper.heading_in_words(67.4)).to eq "northeast" }
    end

    describe "east" do
      it { expect(helper.heading_in_words(67.5)).to eq "east" }
    end

    describe "northwest" do
      it { expect(helper.heading_in_words(-22.6)).to eq "northwest" }
    end
  end
end
