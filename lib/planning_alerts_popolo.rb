module Everypolitician
  module Popolo
    # Copied from the everypolitician-popolo Gem so we can override the class it returns:
    # https://github.com/everypolitician/everypolitician-popolo/blob/62d5dae9b15cf7fd3e5220378d8e777ae91a4b89/lib/everypolitician/popolo.rb#L20
    def self.parse(popolo_string)
      popolo = ::JSON.parse(popolo_string, symbolize_names: true)
      PlanningAlertsPopolo.new(popolo)
    end
  end
end

class PlanningAlertsPopolo < EveryPolitician::Popolo::JSON
  def persons_for_organization_name(name)
    organization_id = find_organization_by_name(name).id
    organization_memberships = councillor_memberships_for_organization_id(organization_id)

    organization_memberships.collect do |m|
      person = find_person_by_id(m.person_id)
      party = organizations.find { |o| o.classification == "party" && o.id == m.on_behalf_of_id }
      party_name = party.name unless party.name == "unknown"

      EveryPolitician::Popolo::Person.new(person.document.merge(party: party_name))
    end
  end

  def find_organization_by_name(name)
    organizations.find { |o| o.name == name }
  end

  def find_party_organization_by_id(id)
    organizations.find { |o| o.classification == "party" && o.id == id }
  end

  def councillor_memberships_for_organization_id(id)
    memberships.find_all do |m|
      m.role == "councillor" && m.organization_id == id
    end
  end

  def find_person_by_id(id)
    persons.find { |p| p.id == id }
  end
end

