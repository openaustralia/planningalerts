# frozen_string_literal: true

require "spec_helper"

describe Admin::AuthoritiesHelper do
  describe "#load_councillors_response_text" do
    it "all councillors load successfully" do
      valid_councillors = [create(:councillor), create(:councillor)]

      expect(helper.load_councillors_response_text(valid_councillors))
        .to eql "Successfully loaded/updated 2 councillors."
    end

    it "there were no councillors to load" do
      expect(helper.load_councillors_response_text([]))
        .to eql "Could not find any councillors in the data to load."
    end

    it "all councillors failed to load due to errors" do
      invalid_councillors = [
        build(:councillor, name: "Fred Dagg", email: nil),
        build(:councillor, name: "Luke Lucas", image_url: "http://example.com")
      ]

      expect(helper.load_councillors_response_text(invalid_councillors))
        .to eql "Skipped loading 2 councillors. Fred Dagg (Email can't be blank) and Luke Lucas (Image url must be HTTPS)."
    end

    it "some councillors load successfully and some fail" do
      councillors = [
        build(:councillor),
        build(:councillor, name: "James Jamison", image_url: "http://example.com")
      ]

      expect(helper.load_councillors_response_text(councillors))
        .to eql "Successfully loaded/updated 1 councillor. Skipped loading 1 councillor. James Jamison (Image url must be HTTPS)."
    end
  end
end
