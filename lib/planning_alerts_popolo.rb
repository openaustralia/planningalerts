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
  def councillors_for_authority(name)
    organization_memberships = councillor_memberships_for_organization(name)

    organization_memberships.map do |membership|
      person_with_party_for_membership(membership)
    end
  end

  def find_organization_by_name(name)
    organizations.find { |o| o.name == name }
  end

  def find_party_organization_by_id(id)
    organizations.find do |o|
      o.classification == "party" && o.id == id
    end
  end

  def councillor_memberships_for_organization(name)
    memberships.find_all do |m|
      m.role == "councillor" &&
      m.organization_id == find_organization_by_name(name).id
    end
  end

  def find_person_by_id(id)
    persons.find { |p| p.id == id }
  end

  def person_with_party_for_membership(membership)
    person = find_person_by_id(membership.person_id)
    party = find_party_organization_by_id(membership.on_behalf_of_id)
    party_name = party.name unless party.name == "unknown"

    EveryPolitician::Popolo::Person.new(
      person.document.merge(party: party_name)
    )
  end
end

