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
end
