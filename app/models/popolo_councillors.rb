# typed: strict
# frozen_string_literal: true

class PersonWithExtraFields < Everypolitician::Popolo::Person
  extend T::Sig

  sig { params(person: Everypolitician::Popolo::Person, party_name: T.nilable(String), end_date: T.nilable(String)).void }
  def initialize(person, party_name, end_date)
    super(
      person.document.merge(party: party_name, end_date: end_date)
    )
  end
end

class PopoloCouncillors
  extend T::Sig

  sig { returns(Everypolitician::Popolo::JSON) }
  attr_accessor :popolo

  sig { params(popolo: Everypolitician::Popolo::JSON).void }
  def initialize(popolo)
    @popolo = popolo
  end

  sig { params(name: String).returns(T::Array[PersonWithExtraFields]) }
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

  sig { params(membership: Everypolitician::Popolo::Membership).returns(PersonWithExtraFields) }
  def person_with_party_and_end_date_for_membership(membership)
    person = popolo.persons.find_by(id: membership.person_id)
    end_date = membership.end_date
    party = popolo.organizations.find_by(id: membership.on_behalf_of_id, classification: "party")
    party_name = party.name unless party.name == "unknown"

    PersonWithExtraFields.new(person, party_name, end_date)
  end
end
