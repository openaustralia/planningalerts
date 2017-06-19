require 'spec_helper'

RSpec.describe SuggestedCouncillor, type: :model do
  it "should require a name" do
    user = SuggestedCouncillor.create( name: "")
    user.valid?
    user.errors.should have_key(:name)
  end

  it "should require an email" do
    user = SuggestedCouncillor.create(email: "")
    user.valid?
    user.errors.should have_key(:email)
  end

  it "should require an authority_id" do
    user = SuggestedCouncillor.create(authority_id: "")
    user.valid?
    user.errors.should have_key(:authority_id)
  end
end
