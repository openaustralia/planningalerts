require 'spec_helper'

describe SignupController, "confirming" do
  it "should set the alert to be confirmed" do
    user = mock_model(User)
    User.should_receive(:find).with(:first, :conditions => {:confirm_id => "1234"}).and_return(user)
    user.should_receive(:confirmed=).with(true)
    get :confirmed, :cid => "1234"
  end
end
