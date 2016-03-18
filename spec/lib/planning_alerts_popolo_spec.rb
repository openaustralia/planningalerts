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

  describe "#find_organization_by_name" do
    it "finds an organization by name" do
      expected_organization = EveryPolitician::Popolo::Organization.new(id: "foo_bar", name: "Foo Bar")
      popolo = PlanningAlertsPopolo.new(organizations: [{id: "foo_bar", name: "Foo Bar"}])

      expect(popolo.find_organization_by_name("Foo Bar")).to eql expected_organization
    end
  end

  describe "#find_party_organization_by_id" do
    it "successfully finds a party" do
      popolo = PlanningAlertsPopolo.new(
        organizations: [{id: "mcgillicuddy_party",
                        name: "McGillicuddy Serious Party",
                        classification: "party"}]
      )

      expect(popolo.find_party_organization_by_id("mcgillicuddy_party").name)
        .to eq "McGillicuddy Serious Party"
    end

    it "doesn’t return non party organization" do
      popolo = PlanningAlertsPopolo.new(
        organizations: [{id: "mcgillicuddy_party",
                        name: "McGillicuddy Serious Party",
                        classification: "tomato"}]
      )

      expect(popolo.find_party_organization_by_id("mcgillicuddy_party"))
        .to eq nil
    end
  end

  describe "#councillor_memberships_for_organization_id" do
    it "returns all memberships with role “councillor” for an organisation" do
      popolo = PlanningAlertsPopolo.new(
        memberships: [
          {
            person_id: "kevin_mack",
            organization_id: "foo_bar",
            role: "councillor"
          },
          {
            person_id: "ross_jackson",
            organization_id: "foo_bar",
            role: "councillor"
          },
          {
            person_id: "ross_jackson",
            organization_id: "foo_bar",
            role: "mayor"
          },
          {
            person_id: "ming_zhang",
            organization_id: "other_council",
            role: "councillor"
          }
        ]
      )

      memberships = popolo.councillor_memberships_for_organization_id("foo_bar")

      expect(memberships[0].person_id).to eq "kevin_mack"
      expect(memberships[1].person_id).to eq "ross_jackson"
    end
  end

  describe "#find_person_by_id" do
    it "finds a person by their id" do
      popolo = PlanningAlertsPopolo.new(
        persons: [{name: "Kevin Mack", id: "kevin_mack"},
                  {name: "Steve Buscemi", id: "steve_buscemi"}]
      )

      expect(popolo.find_person_by_id("kevin_mack").name).to eq "Kevin Mack"
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
