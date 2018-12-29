# frozen_string_literal: true

require "spec_helper"

describe ReplyNotifier do
  describe "#notify_comment_author" do
    let(:application) do
      create(:geocoded_application,
             address: "24 Bruce Road Glenbrook",
             description: "A lovely house")
    end
    let(:councillor) { create(:councillor, name: "Louise Councillor") }
    let(:comment) do
      create(:comment,
             :confirmed,
             councillor: councillor,
             email: "matthew@openaustralia.org",
             application: application)
    end
    let(:reply) { create(:reply, comment: comment, councillor: councillor) }
    let(:notifier) { ReplyNotifier.notify_comment_author(reply) }
    let(:email_intro_text) { "Local councillor Louise Councillor replied" }

    it { expect(notifier.to).to eq ["matthew@openaustralia.org"] }
    it { expect(notifier.sender).to eq "contact@planningalerts.org.au" }
    it { expect(notifier.from).to eq ["contact@planningalerts.org.au"] }
    it { expect(notifier.subject).to eq "Local Councillor Louise Councillor replied to your message" }
    it { expect(notifier.text_part).to have_body_text email_intro_text }
    it { expect(notifier.html_part).to have_body_text email_intro_text }
  end
end
