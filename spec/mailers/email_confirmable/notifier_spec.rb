require 'spec_helper'

describe EmailConfirmable::Notifier do
  describe "confirm alert" do
    let(:alert) { mock_model(Alert, confirm_id: "a237bfc", email: "matthew@oaf.org.au") }
    let(:notifier) { EmailConfirmable::Notifier.confirm(alert) }

    it do
      notifier.from.should == ["contact@planningalerts.org.au"]
    end

    it "should go to the alert's email address" do
      notifier.to.should == ["matthew@oaf.org.au"]
    end

    it "should tell the person what the email is about" do
      notifier.subject.should == "Please confirm your planning alert"
    end

    it do
      notifier.body.parts.find { |p| p.content_type.match /plain/ }.body.raw_source.should == <<-EOF
Please click on the link below to confirm you want to receive email alerts for planning applications near :

http://dev.planningalerts.org.au/alerts/a237bfc/confirmed

If your email program does not let you click on this link, just copy and paste it into your web browser and hit return.
      EOF
    end

    it do
      notifier.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source.should == <<-EOF
<p>Please click on the link below to confirm you want to receive email alerts for planning applications near :</p>
<a href="http://dev.planningalerts.org.au/alerts/a237bfc/confirmed">Confirm your alert</a>
<p>If your email program does not let you click on this link, just copy and paste it into your web browser and hit return.</p>
      EOF
    end
  end

  describe "confirm comment" do
    let(:authority) { mock_model(Authority) }
    let(:application) { mock_model(Application, authority: authority, address: "10 Smith Street",
      description: "A building", council_reference: "27B/6") }
    let(:comment) { mock_model(Comment, text: "This is a comment", confirm_id: "sdbfjsd3rs", email: "matthew@openaustralia.org",
      application: application) }
    let(:notifier) { EmailConfirmable::Notifier.confirm(comment) }

    it do
      notifier.from.should == ["contact@planningalerts.org.au"]
    end

    it "should go to the comment's email address" do
      notifier.to.should == ["matthew@openaustralia.org"]
    end

    it "should tell the person what the email is about" do
      notifier.subject.should == "Please confirm your comment"
    end

    it do
      notifier.body.parts.find { |p| p.content_type.match /plain/ }.body.raw_source.should == <<-EOF
Please click on the link below to confirm your comment. Only then will your comment be visible to others and be sent off to . If you didn't make a comment, then simply ignore this email and nothing further will happen.

http://dev.planningalerts.org.au/comments/sdbfjsd3rs/confirmed

If your email program does not let you click on this link, just copy and paste it into your web browser and hit return.

Your comment:
This is a comment

On the application:
10 Smith Street (27B/6)

A building
      EOF
    end

    it do
      notifier.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source.should == <<-EOF
<p>
Please click on the link below to confirm your comment.
Only then will your comment be visible to others and be sent off to .
If you didn't make a comment, then simply ignore this email and nothing further will happen.
</p>
<a href="http://dev.planningalerts.org.au/comments/sdbfjsd3rs/confirmed">Confirm your comment</a>
<p>If your email program does not let you click on this link, just copy and paste it into your web browser and hit return.</p>
<p>
Your comment:
This is a comment
</p>
<p>
On the application:
10 Smith Street
(27B/6)
</p>
<p>A building</p>
      EOF
    end
  end
end
