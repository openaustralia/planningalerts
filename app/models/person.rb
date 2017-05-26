class Person
  def initialize(email: nil)
    @email = email
  end

  attr_reader :email
end
