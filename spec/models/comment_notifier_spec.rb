require 'spec_helper'

describe CommentNotifier do
  before :each do
    authority = mock_model(Authority, :full_name => "Foo Council")
    application = mock_model(Application, :authority => authority, :address => "12 Foo Rd", :council_reference => "001", :description => "Building something")
    @comment = mock_model(Comment, :email => "foo@bar.com", :application => application, :confirm_id => "abcdef", :text => "A good thing")
  end

  it "should be sent to the user's email address" do
    notifier = CommentNotifier.create_confirm(@comment)
    notifier.to.should == [@comment.email]
  end
  
  it "should be from the main planningalerts email address" do
    notifier = CommentNotifier.create_confirm(@comment)
    notifier.from.should == ["contact@planningalerts.org.au"]
    notifier.from_addrs.first.name.should == "PlanningAlerts.org.au"
  end
  
  it "should say in the subject line it is an email to confirm a comment" do
    notifier = CommentNotifier.create_confirm(@comment)
    notifier.subject.should == "Please confirm your comment"
  end
  
  it "should include a confirmation url" do
    notifier = CommentNotifier.create_confirm(@comment)
    notifier.body.should include_text("http://dev.planningalerts.org.au/comments/abcdef/confirmed")
  end
end