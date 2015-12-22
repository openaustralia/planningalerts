require "spec_helper"

describe ReportNotifier do
  before :each do
    @application = mock_model(Application, id: "2")
    @comment = mock_model(Comment, application: @application, text: "I'm saying something abusive",
      name: "Jack Rude", email: "rude@foo.com", id: "23")
    @report = mock_model(Report, name: "Joe Reporter", email: "reporter@foo.com", comment: @comment,
      details: "It's very rude!")
    @notifier = ReportNotifier.notify(@report)
  end
  
  it "should come from the reporter's email address" do
    @notifier.from.should == ["reporter@foo.com"]
  end
  
  it "should go to the moderator email address" do
    @notifier.to.should == ["moderator@planningalerts.org.au"]
  end
  
  it "should tell the moderator what the email is about" do
    @notifier.subject.should == "PlanningAlerts: Abuse report"
  end
  
  it "should tell the moderator everything they need to know to decide on what to do with the report" do
    @notifier.body.to_s.should == <<-EOF
The abuse report was completed by Joe Reporter (reporter@foo.com) who said:
It's very rude!

The original comment was written by Jack Rude (rude@foo.com) who said:
I'm saying something abusive

The original comment can be found at:
http://dev.planningalerts.org.au/applications/2#comment23

To edit/hide/delete this comment:
http://dev.planningalerts.org.au/admin/comments/23/edit
    EOF
  end
end
