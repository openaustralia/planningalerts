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

  describe "#find_organization_by_name" do
    it "finds an organization by name" do
      expected_organization = EveryPolitician::Popolo::Organization.new(id: "foo_bar", name: "Foo Bar")
      popolo = PlanningAlertsPopolo.new(organizations: [{id: "foo_bar", name: "Foo Bar"}])

      expect(popolo.find_organization_by_name("Foo Bar")).to eql expected_organization
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
end
