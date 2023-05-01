# frozen_string_literal: true

require "spec_helper"

RSpec.describe NoRepliesMailbox do
  it "sends off a reply" do
    inbound_email = process(from: "matthew@oaf.org.au")
    expect(inbound_email).to have_been_delivered
  end

  it "sends off a reply with auto-submitted set to no" do
    inbound_email = process(from: "matthew@oaf.org.au", "Auto-Submitted" => "no")
    expect(inbound_email).to have_been_delivered
  end

  it "ignores an email from a non-human" do
    inbound_email = process(from: "matthew@oaf.org.au", "Auto-Submitted" => "auto-generated")
    expect(inbound_email).to have_bounced
  end
end
