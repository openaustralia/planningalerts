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
end
