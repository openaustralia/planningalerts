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
    authority = organizations.find_by(name: name)
    councillor_memberships = memberships.where(
      organization_id: authority.id,
      role: "councillor"
    )

    councillor_memberships.map do |membership|
      person_with_party_for_membership(membership)
    end
  end

  def person_with_party_for_membership(membership)
    person = persons.find_by(id: membership.person_id)
    party = organizations.find_by(id: membership.on_behalf_of_id, classification: "party")
    party_name = party.name unless party.name == "unknown"

    EveryPolitician::Popolo::Person.new(
      person.document.merge(party: party_name)
    )
  end
end

