# frozen_string_literal: true

require "spec_helper"

RSpec.describe UnsubscribesMailbox do
  let(:alert) { create(:alert, confirm_id: "0123456789abcdef0123") }

  it "is what an email to the alert's unsubscribe address is routed to" do
    mail = Mail.new(from: "person@example.com", to: "unsubscribe+#{alert.confirm_id}@planningalerts.org.au", subject: "unsubscribe", body: "")
    inbound_email = ActionMailbox::InboundEmail.create_and_extract_message_id!(mail.to_s)
    expect(ApplicationMailbox.router.mailbox_for(inbound_email)).to eq described_class
  end

  it "unsubscribes the alert" do
    process(from: "person@example.com", to: "unsubscribe+#{alert.confirm_id}@planningalerts.org.au")
    expect(alert.reload).to be_unsubscribed
  end

  it "records the unsubscribe like a one-click unsubscribe does" do
    process(from: "person@example.com", to: "unsubscribe+#{alert.confirm_id}@planningalerts.org.au")
    expect(alert.reload.unsubscribed_by).to be_nil
    expect(alert.unsubscribed_at).to be_present
  end

  it "finds the alert when the address is in a different case" do
    process(from: "person@example.com", to: "Unsubscribe+#{alert.confirm_id}@PlanningAlerts.org.au")
    expect(alert.reload).to be_unsubscribed
  end

  it "finds the alert when a mail client has upcased the confirm id" do
    process(from: "person@example.com", to: "unsubscribe+#{alert.confirm_id.upcase}@planningalerts.org.au")
    expect(alert.reload).to be_unsubscribed
  end

  it "does nothing when no alert has that confirm id" do
    inbound_email = process(from: "person@example.com", to: "unsubscribe+nosuchalert@planningalerts.org.au")
    expect(inbound_email).to have_been_delivered
    expect(alert.reload).not_to be_unsubscribed
  end

  it "leaves an alert that is already unsubscribed as it was" do
    alert.unsubscribe_by_bounce!
    unsubscribed_at = alert.reload.unsubscribed_at
    process(from: "person@example.com", to: "unsubscribe+#{alert.confirm_id}@planningalerts.org.au")
    alert.reload
    expect(alert.unsubscribed_at).to eq unsubscribed_at
    expect(alert.unsubscribed_by).to eq "bounce"
  end

  it "does not unsubscribe other alerts" do
    other = create(:alert, confirm_id: "ffffffffffffffffffff")
    process(from: "person@example.com", to: "unsubscribe+#{alert.confirm_id}@planningalerts.org.au")
    expect(other.reload).not_to be_unsubscribed
  end
end
