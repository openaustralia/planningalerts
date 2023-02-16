# frozen_string_literal: true

require "spec_helper"

describe Application do
  let(:authority) { create(:authority) }

  describe "validation" do
    describe "council_reference" do
      it { expect(build(:application_with_no_version, council_reference: "")).not_to be_valid }

      context "when one application already exists" do
        before do
          create(:geocoded_application, council_reference: "A01", authority:)
        end

        let(:authority2) { create(:authority, full_name: "A second authority") }

        it { expect(build(:application_with_no_version, council_reference: "A01", authority:)).not_to be_valid }
        it { expect(build(:application_with_no_version, council_reference: "A02", authority:)).to be_valid }
        it { expect(build(:application_with_no_version, council_reference: "A01", authority: authority2)).to be_valid }
      end
    end

    describe "date_scraped" do
      it { expect(build(:application_with_no_version, date_scraped: nil)).not_to be_valid }
    end

    describe "address" do
      it { expect(build(:application_with_no_version, address: "")).not_to be_valid }
    end

    describe "description" do
      it { expect(build(:application_with_no_version, description: "")).not_to be_valid }
    end

    describe "info_url" do
      it { expect(build(:application_with_no_version, info_url: "")).not_to be_valid }
      it { expect(build(:application_with_no_version, info_url: "http://blah.com?p=1")).to be_valid }
      it { expect(build(:application_with_no_version, info_url: "foo")).not_to be_valid }
    end

    describe "date_received" do
      it { expect(build(:application_with_no_version, date_received: nil)).to be_valid }

      context "when the date today is 1 january 2001" do
        around do |test|
          Timecop.freeze(Date.new(2001, 1, 1)) { test.run }
        end

        it { expect(build(:application_with_no_version, date_received: Date.new(2002, 1, 1))).not_to be_valid }
        it { expect(build(:application_with_no_version, date_received: Date.new(2000, 1, 1))).to be_valid }
      end
    end

    describe "on_notice" do
      it { expect(build(:application_with_no_version, on_notice_from: nil, on_notice_to: nil)).to be_valid }
      it { expect(build(:application_with_no_version, on_notice_from: Date.new(2001, 1, 1), on_notice_to: Date.new(2001, 2, 1))).to be_valid }
      it { expect(build(:application_with_no_version, on_notice_from: nil, on_notice_to: Date.new(2001, 2, 1))).to be_valid }
      it { expect(build(:application_with_no_version, on_notice_from: Date.new(2001, 1, 1), on_notice_to: nil)).to be_valid }
      it { expect(build(:application_with_no_version, on_notice_from: Date.new(2001, 2, 1), on_notice_to: Date.new(2001, 1, 1))).not_to be_valid }
    end
  end

  describe "#date_scraped" do
    let(:application) { create(:geocoded_application) }

    let(:updated_application) do
      CreateOrUpdateApplicationService.call(
        authority: application.authority,
        council_reference: application.council_reference,
        attributes: {
          description: "An updated description",
          date_scraped: 1.minute.ago
        }
      )
    end

    it "is the initial date scraped" do
      date_scraped = application.first_date_scraped
      expect(updated_application.first_date_scraped).to eq date_scraped
      expect(updated_application.current_version.date_scraped).not_to eq date_scraped
    end
  end

  describe "#comment_email_with_fallback" do
    let(:authority) { create(:authority, email: "council@foo.com") }

    context "when application has comment_email set to nil" do
      let(:application) { create(:geocoded_application, authority:) }

      it "returns the email address of the authority" do
        expect(application.comment_email_with_fallback).to eq "council@foo.com"
      end
    end

    context "when application has comment_email set to specialplace@bar.com" do
      let(:application) { create(:geocoded_application, authority:, comment_email: "specialplace@bar.com") }

      it "returns the overridden email address connected to the application" do
        expect(application.comment_email_with_fallback).to eq "specialplace@bar.com"
      end
    end
  end

  describe "#comment_authority_with_fallback" do
    let(:authority) { create(:authority, full_name: "Foo Council") }

    context "when application has comment_authority set to nil" do
      let(:application) { create(:geocoded_application, authority:) }

      it "returns the the full name of the authority" do
        expect(application.comment_authority_with_fallback).to eq "Foo Council"
      end
    end

    context "when application has comment_authority set to Special Council" do
      let(:application) { create(:geocoded_application, authority:, comment_authority: "Special Council") }

      it "returns the overridden name connected to the application" do
        expect(application.comment_authority_with_fallback).to eq "Special Council"
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

  describe "#official_submission_period_expired?" do
    context "when the ‘on notice to’ date is not set" do
      let(:application) do
        create(:geocoded_application, on_notice_to: nil)
      end

      it { expect(application).not_to be_official_submission_period_expired }
    end

    context "when the ‘on notice to’ date has passed" do
      let(:application) do
        create(:geocoded_application, on_notice_to: Time.zone.today - 1.day)
      end

      it { expect(application.official_submission_period_expired?).to be true }
    end

    context "when the ‘on notice to’ date is in the future" do
      let(:application) do
        create(:geocoded_application, on_notice_to: Time.zone.today + 1.day)
      end

      it { expect(application.official_submission_period_expired?).to be false }
    end
  end
end
