# frozen_string_literal: true

require "spec_helper"

describe CommentMailer do
  describe "#notify_authority" do
    let(:application) do
      create(
        :geocoded_application,
        authority: create(:contactable_authority),
        address: "12 Foo Rd",
        council_reference: "X/001",
        description: "Building something",
        id: 123
      )
    end

    let(:comment) do
      create(:confirmed_comment,
             user: create(:user, email: "foo@bar.com"),
             name: "Matthew",
             application: application,
             text: "It's a good thing.\n\nOh yes it is.",
             address: "1 Bar Street")
    end

    context "with default theme" do
      let(:notifier) { described_class.notify_authority(comment) }

      it "is sent to the planning authority's feedback email address" do
        expect(notifier.to).to eq([comment.application.authority.email])
      end

      it "has the from as the main planningalerts email address" do
        expect(notifier.from).to eq(["contact@planningalerts.org.au"])
      end

      it "is reply-to be the email address of the person who made the comment" do
        expect(notifier.reply_to).to eq([comment.email])
      end

      it "says in the subject line it is a comment on a development application" do
        expect(notifier.subject).to eq("Comment on application X/001")
      end

      it "has specific information in the body of the email" do
        expect(notifier.text_part.body.to_s).to eq(Rails.root.join("spec/mailers/regression/comment_mailer/email1.txt").read)
      end

      it "formats paragraphs correctly in the html version of the email" do
        expect(notifier.html_part.body.to_s).to include Rails.root.join("spec/mailers/regression/comment_mailer/email1.html").read
      end
    end
  end
end
