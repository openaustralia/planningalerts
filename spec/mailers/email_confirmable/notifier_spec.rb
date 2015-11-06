require 'spec_helper'

describe EmailConfirmable::Notifier do
  context "alert" do
    let(:object) { mock_model(Alert, confirm_id: "a237bfc", email: "matthew@oaf.org.au") }

    context "default theme" do
      let(:notifier) { EmailConfirmable::Notifier.confirm("default", object) }

      describe "confirm" do

        it "should come from the planningalerts' normal email" do
          notifier.from.should == ["contact@planningalerts.org.au"]
        end

        it "should go to the alert's email address" do
          notifier.to.should == ["matthew@oaf.org.au"]
        end

        it "should tell the person what the email is about" do
          notifier.subject.should == "Please confirm your planning alert"
        end

        it do
          notifier.body.parts.find { |p| p.content_type.match /plain/ }.body.raw_source.should == Rails.root.join("spec/mailers/regression/email_confirmable/alert.txt").read
        end

        it do
          notifier.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source.should == Rails.root.join("spec/mailers/regression/email_confirmable/alert.html").read
        end
      end
    end

    context "nsw theme" do
      let(:notifier) { EmailConfirmable::Notifier.confirm("nsw", object) }

      describe "confirm" do

        it "should come from the nsw planningalerts' normal email" do
          notifier.from.should == ["contact@nsw.127.0.0.1.xip.io"]
        end

        it "should go to the alert's email address" do
          notifier.to.should == ["matthew@oaf.org.au"]
        end

        it "should tell the person what the email is about" do
          notifier.subject.should == "Please confirm your planning alert"
        end

        it do
          notifier.body.parts.find { |p| p.content_type.match /plain/ }.body.raw_source.should == Rails.root.join("spec/mailers/regression/email_confirmable/alert_nsw.txt").read
        end

        it do
          notifier.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source.should == Rails.root.join("spec/mailers/regression/email_confirmable/alert_nsw.html").read
        end
      end
    end

  end

  context "comment" do
    let(:authority) { mock_model(Authority) }
    let(:application) { mock_model(Application, authority: authority, address: "10 Smith Street",
      description: "A building", council_reference: "27B/6") }
    let(:object) { mock_model(Comment, text: "This is a comment", confirm_id: "sdbfjsd3rs", email: "matthew@openaustralia.org",
      application: application, recipient_name: nil) }

    context "default theme" do
      let(:notifier) { EmailConfirmable::Notifier.confirm("default", object) }

      describe "confirm" do
        it "should come from the planningalerts' normal email" do
          notifier.from.should == ["contact@planningalerts.org.au"]
        end

        it "should go to the comment's email address" do
          notifier.to.should == ["matthew@openaustralia.org"]
        end

        it "should tell the person what the email is about" do
          notifier.subject.should == "Please confirm your comment"
        end

        it do
          notifier.body.parts.find { |p| p.content_type.match /plain/ }.body.raw_source.should == Rails.root.join("spec/mailers/regression/email_confirmable/comment.txt").read
        end

        it do
          notifier.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source.should == Rails.root.join("spec/mailers/regression/email_confirmable/comment.html").read
        end
      end
    end

    context "nsw theme" do
      let(:notifier) { EmailConfirmable::Notifier.confirm("nsw", object) }

      describe "confirm" do
        it "should come from the nsw planningalerts' normal email" do
          notifier.from.should == ["contact@nsw.127.0.0.1.xip.io"]
        end

        it "should go to the comment's email address" do
          notifier.to.should == ["matthew@openaustralia.org"]
        end

        it "should tell the person what the email is about" do
          notifier.subject.should == "Please confirm your comment"
        end

        it do
          notifier.body.parts.find { |p| p.content_type.match /plain/ }.body.raw_source.should == Rails.root.join("spec/mailers/regression/email_confirmable/comment_nsw.txt").read
        end

        it do
          notifier.body.parts.find { |p| p.content_type.match /html/ }.body.raw_source.should == Rails.root.join("spec/mailers/regression/email_confirmable/comment_nsw.html").read
        end
      end
    end

  end
end
