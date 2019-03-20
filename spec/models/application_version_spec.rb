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

      it "should allow multiple versions for the same application that are not current" do
        create(:application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: false)
        expect(version2).to be_valid
      end

      it "should allow one version for the same application to be current" do
        create(:application_version, application: application1, current: false)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).to be_valid
      end

      it "should allow one version for the same application to be current" do
        create(:application_version, application: application1, current: true)
        version2 = build(:application_version, application: application1, current: false)
        expect(version2).to be_valid
      end

      it "should not allow more than one version to be current" do
        create(:application_version, application: application1, current: true)
        version2 = build(:application_version, application: application1, current: true)
        expect(version2).to_not be_valid
      end

      it "should allow more than one version to be current for different applications" do
        create(:application_version, application: application1, current: true)
        version2 = build(:application_version, application: application2, current: true)
        expect(version2).to be_valid
      end
    end
  end
end
