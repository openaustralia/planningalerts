require "spec_helper"

describe PlanningAlertsPopolo do
  describe "#councillors_for_authority" do
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
      expect(popolo.councillors_for_authority("Albury City Council")).to eql expected_persons_array
    end
  end

  describe "#person_with_party_for_membership" do
    it "returns a person with their party" do
      popolo = PlanningAlertsPopolo.new(
        persons: [{ name: "Kevin Mack", id: "kevin_mack" }],
        organizations: [
          {
            name: "Sunripe Tomato Party",
            id: "sunripe_tomato_party",
            classification: "party"
          },
          {
            name: "Marrickville Council",
            id: "marrickville_council",
            classification: "legislature"
          }
        ],
        memberships: [
          {
            person_id: "kevin_mack",
            organization_id: "marrickville_council",
            on_behalf_of_id: "sunripe_tomato_party"
          }
        ]
      )
      membership = popolo.memberships.first

      expect(popolo.person_with_party_for_membership(membership).party)
        .to eq "Sunripe Tomato Party"
      expect(popolo.person_with_party_for_membership(membership).name)
        .to eq "Kevin Mack"
    end
  end
end
