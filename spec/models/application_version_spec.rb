# frozen_string_literal: true

require "spec_helper"

describe ApplicationVersion do
  describe "validations" do
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

      it "allows one version for the same application to be current with second version current" do
        create(:geocoded_application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).to be_valid
      end

      it "allows one version for the same application to be current with first version current" do
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
        date_scraped:
      )
      expect(new_version.changed_data_attributes).to eq(
        "description" => "A new description",
        "date_scraped" => new_version.date_scraped
      )
    end
  end
end
