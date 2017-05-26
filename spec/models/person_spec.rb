require 'spec_helper'

RSpec.describe Person, type: :model do
  it "they have an email" do
    expect(Person.new(email: "elzia@example.org").email).to eql "elzia@example.org"
  end
end
