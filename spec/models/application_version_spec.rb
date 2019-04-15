# frozen_string_literal: true

require "spec_helper"

describe ApplicationVersion do
  describe "validations" do
    describe "date_scraped" do
      it { expect(build(:application_version, date_scraped: nil)).not_to be_valid }
    end

    describe "address" do
      it { expect(build(:application_version, address: "")).not_to be_valid }
    end

    describe "description" do
      it { expect(build(:application_version, description: "")).not_to be_valid }
    end

    describe "info_url" do
      it { expect(build(:application_version, info_url: "")).not_to be_valid }
      it { expect(build(:application_version, info_url: "http://blah.com?p=1")).to be_valid }
      it { expect(build(:application_version, info_url: "foo")).not_to be_valid }
    end

    describe "comment_url" do
      it { expect(build(:application_version, comment_url: nil)).to be_valid }
      it { expect(build(:application_version, comment_url: "http://blah.com?p=1")).to be_valid }
      it { expect(build(:application_version, comment_url: "mailto:m@foo.com?subject=hello+sir")).to be_valid }
      it { expect(build(:application_version, comment_url: "foo")).not_to be_valid }
      it { expect(build(:application_version, comment_url: "mailto:council@lakemac.nsw.gov.au?Subject=Redhead%20Beach%20&%20Surf%20Life%20Saving%20Club,%202A%20Beach%20Road,%20REDHEAD%20%20NSW%20%202290%20DA-1699/2014")).to be_valid }
    end

    describe "date_received" do
      it { expect(build(:application_version, date_received: nil)).to be_valid }

      context "the date today is 1 january 2001" do
        around do |test|
          Timecop.freeze(Date.new(2001, 1, 1)) { test.run }
        end

        it { expect(build(:application_version, date_received: Date.new(2002, 1, 1))).not_to be_valid }
        it { expect(build(:application_version, date_received: Date.new(2000, 1, 1))).to be_valid }
      end
    end

    describe "on_notice" do
      it { expect(build(:application_version, on_notice_from: nil, on_notice_to: nil)).to be_valid }
      it { expect(build(:application_version, on_notice_from: Date.new(2001, 1, 1), on_notice_to: Date.new(2001, 2, 1))).to be_valid }
      it { expect(build(:application_version, on_notice_from: nil, on_notice_to: Date.new(2001, 2, 1))).to be_valid }
      it { expect(build(:application_version, on_notice_from: Date.new(2001, 1, 1), on_notice_to: nil)).to be_valid }
      it { expect(build(:application_version, on_notice_from: Date.new(2001, 2, 1), on_notice_to: Date.new(2001, 1, 1))).not_to be_valid }
    end

    describe "current" do
      # Creates a bare application with no application versions
      let(:application1) do
        application = create_geocoded_application
        application.versions.destroy_all
        application
      end

      let(:application2) do
        application = create_geocoded_application
        application.versions.destroy_all
        application
      end

      it "should allow multiple versions for the same application that are not current" do
        create(:geocoded_application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: false)
        expect(version2).to be_valid
      end

      it "should allow one version for the same application to be current" do
        create(:geocoded_application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).to be_valid
      end

      it "should allow one version for the same application to be current" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application1, current: false)
        expect(version2).to be_valid
      end

      it "should not allow more than one version to be current" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).to_not be_valid
      end

      it "should allow more than one version to be current for different applications" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application2, current: true)
        expect(version2).to be_valid
      end
    end
  end
end
