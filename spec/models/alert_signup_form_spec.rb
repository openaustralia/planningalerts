require "spec_helper"

describe AlertSignupForm do
  describe "#address_for_placeholder" do
    it "has a default address" do
      expect(AlertSignupForm.new.address_for_placeholder).to eql "1 Sowerby St, Goulburn, NSW 2580"
    end

    it "can be set to something else" do
      expect(
        AlertSignupForm.new(
          address_for_placeholder: "5 Boaty St, Boat Face"
        ).address_for_placeholder
     ).to eql "5 Boaty St, Boat Face"
    end
  end
end
