# frozen_string_literal: true

require "spec_helper"

describe NotifySlackCommentDeliveryService do
  let(:notifier) { instance_double(Slack::Notifier) }
  let(:messages) { [] }
  let(:comment) { create(:delivery_failed_comment) }
  let(:authority_name) { comment.application.authority.full_name }
  let(:comment_url) { "http://localhost/admin/comments/#{comment.id}" }
  let(:to) { "planning@council.example.com" }
  let(:email_id) { 42 }
  let(:email_url) { "https://mail.example.com/messages/42" }
  let(:extended_status) { "550 5.1.1 mailbox unavailable" }

  before do
    allow(Slack::Notifier).to receive(:new).and_return(notifier)
    allow(notifier).to receive(:ping) { |message| messages << message }
  end

  def call_service(status:)
    described_class.call(comment:, to:, status:, extended_status:, email_id:, email_url:)
  end

  shared_examples "a message about the comment" do |status|
    it "links to the comment and the email, and names the authority and the address" do
      call_service(status:)
      expect(messages.size).to eq 1
      expect(messages.first).to include(comment_url, email_url, authority_name, to)
    end
  end

  describe "delivered" do
    include_examples "a message about the comment", "delivered"

    it "says the comment was delivered, without the server's response" do
      call_service(status: "delivered")
      expect(messages.first).to include("successfully")
      expect(messages.first).not_to include(extended_status)
    end
  end

  describe "soft_bounce" do
    include_examples "a message about the comment", "soft_bounce"

    it "says the comment soft bounced and includes the server's response" do
      call_service(status: "soft_bounce")
      expect(messages.first).to include("soft bounced", extended_status)
    end
  end

  describe "hard_bounce" do
    include_examples "a message about the comment", "hard_bounce"

    it "says the comment hard bounced and includes the server's response" do
      call_service(status: "hard_bounce")
      expect(messages.first).to include("hard bounced", extended_status)
    end
  end

  describe "held" do
    include_examples "a message about the comment", "held"

    it "says the comment was held and mentions the suppression list, without the server's response" do
      call_service(status: "held")
      expect(messages.first).to include("held", "suppression list")
      expect(messages.first).not_to include(extended_status)
    end
  end

  describe "an unknown status" do
    it "raises without sending anything to Slack" do
      expect { call_service(status: "bounced_eventually") }.to raise_error("Unexpected status")
      expect(messages).to be_empty
    end
  end

  context "when email_url is not passed" do
    # The default goes away in #2236 along with the Cuttlefish code. Delete this context then.
    it "links to the email in Cuttlefish" do
      described_class.call(comment:, to:, status: "hard_bounce", extended_status:, email_id:)
      expect(messages.first).to include("https://cuttlefish.oaf.org.au/emails/42")
    end
  end
end
