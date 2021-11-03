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
        application = create(:geocoded_application)
        application.versions.destroy_all
        application
      end

      let(:application2) do
        application = create(:geocoded_application)
        application.versions.destroy_all
        application
      end

      it "allows multiple versions for the same application that are not current" do
        create(:geocoded_application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: false)
        expect(version2).to be_valid
      end

      it "allows one version for the same application to be current" do
        create(:geocoded_application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).to be_valid
      end

      it "allows one version for the same application to be current" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application1, current: false)
        expect(version2).to be_valid
      end

      it "does not allow more than one version to be current" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).not_to be_valid
      end

      it "allows more than one version to be current for different applications" do
        create(:geocoded_application_version, application: application1, current: true)
        version2 = build(:application_version, application: application2, current: true)
        expect(version2).to be_valid
      end
    end
  end

  describe ".normalise_description" do
    it "allows applications to be blank" do
      expect(described_class.normalise_description("")).to eq("")
    end

    it "starts descriptions with a capital letter" do
      expect(described_class.normalise_description("a description")).to eq("A description")
    end

    it "fixes capitilisation of descriptions all in caps" do
      expect(described_class.normalise_description("DWELLING")).to eq("Dwelling")
    end

    it "does not capitalise descriptions that are partially in lowercase" do
      expect(described_class.normalise_description("To merge Owners Corporation")).to eq("To merge Owners Corporation")
    end

    it "capitalises the first word of each sentence" do
      expect(described_class.normalise_description("A SENTENCE. ANOTHER SENTENCE")).to eq("A sentence. Another sentence")
    end

    it "onlies capitalise the word if it's all lower case" do
      expect(described_class.normalise_description("ab sentence. AB SENTENCE. aB sentence. Ab sentence")).to eq("Ab sentence. AB SENTENCE. aB sentence. Ab sentence")
    end

    it "allows blank sentences" do
      expect(described_class.normalise_description("A poorly.    . formed sentence . \n")).to eq("A poorly. . Formed sentence. ")
    end
  end

  describe ".normalise_address" do
    it "converts words to first letter capitalised form" do
      expect(described_class.normalise_address("1 KINGSTON AVENUE, PAKENHAM")).to eq("1 Kingston Avenue, Pakenham")
    end

    it "does not convert words that are not already all in upper case" do
      expect(described_class.normalise_address("In the paddock next to the radio telescope")).to eq("In the paddock next to the radio telescope")
    end

    it "handles a mixed bag of lower and upper case" do
      expect(described_class.normalise_address("63 Kimberley drive, SHAILER PARK")).to eq("63 Kimberley drive, Shailer Park")
    end

    it "does not affect dashes in the address" do
      expect(described_class.normalise_address("63-81")).to eq("63-81")
    end

    it "does not affect abbreviations like the state names" do
      expect(described_class.normalise_address("1 KINGSTON AVENUE, PAKENHAM VIC 3810")).to eq("1 Kingston Avenue, Pakenham VIC 3810")
    end

    it "does not affect the state names" do
      expect(described_class.normalise_address("QLD VIC NSW SA ACT TAS WA NT")).to eq("QLD VIC NSW SA ACT TAS WA NT")
    end

    it "does not affect the state names with punctuation" do
      expect(described_class.normalise_address("QLD. ,VIC ,NSW, !SA /ACT/ TAS: WA, NT;")).to eq("QLD. ,VIC ,NSW, !SA /ACT/ TAS: WA, NT;")
    end

    it "does not affect codes" do
      expect(described_class.normalise_address("R79813 24X")).to eq("R79813 24X")
    end
  end

  describe "#changed_data_attributes" do
    let(:version) { create(:geocoded_application_version) }

    it "returns all data_attributes if only version" do
      expect(version.changed_data_attributes).to eq version.data_attributes
    end

    it "returns just what's changed" do
      date_scraped = 1.minute.ago
      new_version = create(
        :geocoded_application_version,
        previous_version: version,
        description: "A new description",
        date_scraped: date_scraped
      )
      expect(new_version.changed_data_attributes).to eq(
        "description" => "A new description",
        "date_scraped" => new_version.date_scraped
      )
    end
  end

  describe "#official_submission_period_expired?" do
    context "when the ‘on notice to’ date is not set" do
      let(:version) do
        create(:geocoded_application_version, on_notice_to: nil)
      end

      it { expect(version).not_to be_official_submission_period_expired }
    end

    context "when the ‘on notice to’ date has passed" do
      let(:version) do
        create(:geocoded_application_version, on_notice_to: Time.zone.today - 1.day)
      end

      it { expect(version.official_submission_period_expired?).to be true }
    end

    context "when the ‘on notice to’ date is in the future" do
      let(:version) do
        create(:geocoded_application_version, on_notice_to: Time.zone.today + 1.day)
      end

      it { expect(version.official_submission_period_expired?).to be false }
    end
  end
end
