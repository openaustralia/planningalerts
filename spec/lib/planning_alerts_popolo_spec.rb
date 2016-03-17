require "spec_helper"

describe PlanningAlertsPopolo do
  describe "#persons_for_organization_name" do
    it "finds councillors for a named authority" do
      # TODO: Refactor this so it doesn't use a fixture
      popolo_file = Rails.root.join("spec", "fixtures", "local_councillor_popolo.json")
      popolo = EveryPolitician::Popolo::read(popolo_file)

      expected_persons_array = [
        EveryPolitician::Popolo::Person.new(
          id: "albury_city_council/kevin_mack",
          name: "Kevin Mack",
          email: "kevin@albury.nsw.gov.au",
          image: "https://example.com/kevin.jpg",
          party: nil
        ),
        EveryPolitician::Popolo::Person.new(
          id: "albury_city_council/ross_jackson",
          name: "Ross Jackson",
          email: "ross@albury.nsw.gov.au",
          party: "Liberal"
        )
      ]
      expect(popolo.persons_for_organization_name("Albury City Council")).to eql expected_persons_array
    end
  end
end
