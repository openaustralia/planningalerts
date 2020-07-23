# typed: strict

class PersonWithExtraFields < Everypolitician::Popolo::Person
  sig { returns(T.nilable(String)) }
  def party; end

  sig { returns(T.nilable(String)) }
  def end_date; end
end
