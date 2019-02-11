# frozen_string_literal: true

require "spec_helper"

describe CommentMailer do
  describe "#notify_authority" do
    before :each do
      application = mock_model(Application, authority: create(:contactable_authority), address: "12 Foo Rd", council_reference: "X/001", description: "Building something", id: 123)
      @comment = create(:confirmed_comment, email: "foo@bar.com", name: "Matthew", application: application, text: "It's a good thing.\n\nOh yes it is.", address: "1 Bar Street")
    end

    context "default theme" do
      let(:notifier) { CommentMailer.notify_authority(@comment) }

      it "should be sent to the planning authority's feedback email address" do
        expect(notifier.to).to eq([@comment.application.authority.email])
      end

      it "should have the sender as the main planningalerts email address" do
        expect(notifier.sender).to eq("contact@planningalerts.org.au")
      end

      it "should be from the email address of the person who made the comment" do
        expect(notifier.from).to eq([@comment.email])
      end

      it "should say in the subject line it is a comment on a development application" do
        expect(notifier.subject).to eq("Comment on application X/001")
      end

      it "should have specific information in the body of the email" do
        expect(notifier.text_part.body.to_s).to eq(Rails.root.join("spec", "mailers", "regression", "comment_mailer", "email1.txt").read)
      end

      it "should format paragraphs correctly in the html version of the email" do
        expect(notifier.html_part.body.to_s).to include Rails.root.join("spec", "mailers", "regression", "comment_mailer", "email1.html").read
      end
    end
  end

  describe "#notify_councillor" do
    let(:comment_text) { "It's a good thing.\r\n\r\nOh yes it is." }
    let(:comment) do
      application = create(:geocoded_application, council_reference: "X/001", address: "24 Bruce Road Glenbrook")
      create(:comment_to_councillor, email: "foo@bar.com", name: "Matthew", application: application, text: comment_text, address: "1 Bar Street")
    end

    context "default theme" do
      let(:notifier) { CommentMailer.notify_councillor(comment) }

      it { expect(notifier.to).to eql [comment.councillor.email] }
      it { expect(notifier.from).to eql ["replies@planningalerts.org.au"] }
      it { expect(notifier.reply_to).to eql ["replies@planningalerts.org.au"] }
      it { expect(notifier.sender).to eql "contact@planningalerts.org.au" }
      it { expect(notifier.subject).to eql "Planning application at 24 Bruce Road Glenbrook" }
      it { expect(notifier.text_part).to have_content "It's a good thing." }
      it { expect(notifier.html_part).to have_content "It's a good thing." }
    end
  end

  describe "#send_comment_via_writeit!" do
    around do |test|
      with_modified_env(writeit_config_variables) do
        test.run
      end
    end

    let(:comment) do
      councillor = create(:councillor, popolo_id: "marrickville_council/chris_woods")
      create(:comment, councillor: councillor)
    end

    it "sends the comment to the WriteIt API, and stores the created WriteIt message’s id on the comment" do
      VCR.use_cassette("writeit") do
        CommentMailer.send_comment_via_writeit!(comment).deliver_now
      end

      expect(comment.writeit_message_id).to eq 5665
    end
  end
end
