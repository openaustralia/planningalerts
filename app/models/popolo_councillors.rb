class PopoloCouncillors
  attr_accessor :popolo

  def initialize(popolo)
    @popolo = popolo
  end

  def for_authority(name)
    # FIXME: We do not handle not finding an organisation in the Popolo
    authority = popolo.organizations.find_by(name: name)
    councillor_memberships = popolo.memberships.where(
      organization_id: authority.id,
      role: "councillor"
    )

    councillor_memberships.map do |membership|
      person_with_party_and_end_date_for_membership(membership)
    end
  end

  def person_with_party_and_end_date_for_membership(membership)
    person = popolo.persons.find_by(id: membership.person_id)
    end_date = membership.end_date
    party = popolo.organizations.find_by(id: membership.on_behalf_of_id, classification: "party")
    party_name = party.name unless party.name == "unknown"

    EveryPolitician::Popolo::Person.new(
      person.document.merge(party: party_name, end_date: end_date)
    )
  end
end
