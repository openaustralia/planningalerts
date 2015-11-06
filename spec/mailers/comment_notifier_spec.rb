require 'spec_helper'

describe CommentNotifier do
  describe "#notify_authority" do
    before :each do
      application = mock_model(Application, authority: create(:contactable_authority), address: "12 Foo Rd", council_reference: "X/001", description: "Building something", id: 123)
      @comment = create(:confirmed_comment, email: "foo@bar.com", name: "Matthew", application: application, text: "It's a good thing.\n\nOh yes it is.", address: "1 Bar Street")
    end

    context "default theme" do
      let(:notifier) { CommentNotifier.notify_authority("default", @comment) }

      it "should be sent to the planning authority's feedback email address" do
        notifier.to.should == [@comment.application.authority.email]
      end

      it "should have the sender as the main planningalerts email address" do
        notifier.sender.should == "contact@planningalerts.org.au"
      end

      it "should be from the email address of the person who made the comment" do
        notifier.from.should == [@comment.email]
      end

      it "should say in the subject line it is a comment on a development application" do
        notifier.subject.should == "Comment on application X/001"
      end

      it "should have specific information in the body of the email" do
        notifier.text_part.body.to_s.should == Rails.root.join("spec/mailers/regression/comment_notifier/email1.txt").read
      end

      it "should format paragraphs correctly in the html version of the email" do
        notifier.html_part.body.to_s.should include Rails.root.join("spec/mailers/regression/comment_notifier/email1.html").read
      end
    end

    context "nsw theme" do
      let(:notifier) { CommentNotifier.notify_authority("nsw", @comment) }

      it "should be sent to the planning authority's feedback email address" do
        notifier.to.should == [@comment.application.authority.email]
      end

      it "should have the sender as the nsw planningalerts email address" do
        notifier.sender.should == "contact@nsw.127.0.0.1.xip.io"
      end

      it "should be from the email address of the person who made the comment" do
        notifier.from.should == [@comment.email]
      end

      it "should say in the subject line it is a comment on a development application" do
        notifier.subject.should == "Comment on application X/001"
      end

      it "should have specific information in the body of the email" do
        notifier.text_part.body.to_s.should == Rails.root.join("spec/mailers/regression/comment_notifier/email2.txt").read
      end

      it "should format paragraphs correctly in the html version of the email" do
        notifier.html_part.body.to_s.should include Rails.root.join("spec/mailers/regression/comment_notifier/email2.html").read
      end
    end
  end

  describe "#notify_councillor" do
    let(:comment_text) { "It's a good thing.\n\nOh yes it is." }
    let(:comment) do
      VCR.use_cassette('planningalerts') do
        application = create(:application, council_reference: "X/001", address: "24 Bruce Road Glenbrook")
        create(:comment_to_councillor, email: "foo@bar.com", name: "Matthew", application: application, text: comment_text, address: "1 Bar Street")
      end
    end

    context "default theme" do
      let(:notifier) { CommentNotifier.notify_councillor("default", comment) }

      it { expect(notifier.to).to eql [comment.councillor.email] }
      it { expect(notifier.sender).to eql "contact@planningalerts.org.au" }
      it { expect(notifier.subject).to eql "Planning application at 24 Bruce Road Glenbrook" }
      it { expect(notifier.text_part).to have_content comment_text }
      it { expect(notifier.html_part).to have_content comment_text }

      # TODO
      it "should be from the special email address we set up to accept replies" do
        # expect(notifier.from).to eql ["???"]
        pending "We haven't worked out what this should be"
      end
    end

    context "nsw theme" do
      # It should not be enabled for the NSW theme
    end
  end
end
