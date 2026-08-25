# frozen_string_literal: true

require "spec_helper"

describe PostalController do
  let(:private_key) { OpenSSL::PKey::RSA.new(2048) }
  let(:alert_id) { 123 }
  let(:comment_id) { 456 }
  let(:message_id) { 12_345 }
  let(:alert_tag) { "alert-#{alert_id}" }
  let(:comment_tag) { "comment-#{comment_id}" }
  let(:recipient_email) { "eliza@example.org" }
  let(:message_url) { "https://postal.oaf.org.au/org/oaf/servers/planningalerts-comments/messages/#{message_id}" }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:postal, :webhook_public_key).and_return(private_key.public_key.to_pem)
    allow(NotifySlackCommentDeliveryService).to receive(:call)
  end

  def sign(body)
    Base64.strict_encode64(private_key.sign(OpenSSL::Digest.new("SHA1"), body))
  end

  def post_event(body, signature: sign(body))
    request.headers["X-Postal-Signature"] = signature unless signature.nil?
    post :event, body:, format: :json
  end

  def status_event_body(event:, tag:, status: "Sent", details: "Some details", output: "250 OK")
    {
      event:,
      timestamp: 1_598_494_300.5, # 2020-08-27T02:11:40.5Z
      uuid: "0f6f76ec-2e33-4f65-b48b-79688dbd0e01",
      payload: {
        status:,
        details:,
        output:,
        time: 1.22,
        sent_with_ssl: true,
        timestamp: 1_598_494_217.5, # 2020-08-27T02:10:17.5Z
        message: {
          id: message_id,
          token: "abcdef123456",
          direction: "outgoing",
          message_id: "ABC@DEF.foo.com",
          to: recipient_email,
          from: "no-reply@planningalerts.org.au",
          subject: "This is a test email from Postal",
          timestamp: 1_598_494_210.0,
          spam_status: "NotSpam",
          tag:
        }
      }
    }.to_json
  end

  def bounce_event_body(tag:)
    {
      event: "MessageBounced",
      timestamp: 1_598_494_300.5, # 2020-08-27T02:11:40.5Z
      uuid: "0f6f76ec-2e33-4f65-b48b-79688dbd0e02",
      payload: {
        original_message: {
          id: message_id,
          token: "abcdef123456",
          direction: "outgoing",
          message_id: "ABC@DEF.foo.com",
          to: recipient_email,
          from: "no-reply@planningalerts.org.au",
          subject: "This is a test email from Postal",
          timestamp: 1_598_494_210.0,
          spam_status: "NotSpam",
          tag:
        },
        bounce: {
          id: 12_346,
          token: "ghijkl789012",
          direction: "incoming",
          message_id: "GHI@JKL.foo.com",
          to: "psrp@postal.oaf.org.au",
          from: "postmaster@example.org",
          subject: "Mail delivery failed",
          timestamp: 1_598_494_299.0,
          spam_status: "NotSpam",
          tag: nil
        }
      }
    }.to_json
  end

  it "rejects a request with no signature" do
    post_event(status_event_body(event: "MessageSent", tag: alert_tag), signature: nil)
    expect(response).to have_http_status(:forbidden)
  end

  it "rejects a request with an invalid signature" do
    post_event(status_event_body(event: "MessageSent", tag: alert_tag), signature: sign("something else entirely"))
    expect(response).to have_http_status(:forbidden)
  end

  it "rejects a request when no public key is configured" do
    allow(Rails.application.credentials).to receive(:dig).with(:postal, :webhook_public_key).and_return(nil)
    post_event(status_event_body(event: "MessageSent", tag: alert_tag))
    expect(response).to have_http_status(:forbidden)
  end

  it "accepts an event with an unknown tag and does nothing" do
    post_event(status_event_body(event: "MessageSent", tag: "something-else"))
    expect(response).to have_http_status(:ok)
    expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
  end

  it "accepts an event with no tag and does nothing" do
    post_event(status_event_body(event: "MessageSent", tag: nil))
    expect(response).to have_http_status(:ok)
    expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
  end

  it "records a successful delivery of an alert email" do
    alert = create(:alert, id: alert_id)
    post_event(status_event_body(event: "MessageSent", tag: alert_tag))
    expect(response).to have_http_status(:ok)
    alert.reload
    expect(alert.last_delivered_at).to eq Time.zone.at(1_598_494_217.5)
    expect(alert.last_delivered_successfully).to be true
    expect(alert.unsubscribed).to be false
    expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
  end

  it "records a successful delivery of a comment email" do
    comment = create(:comment, id: comment_id)
    post_event(status_event_body(event: "MessageSent", tag: comment_tag))
    expect(response).to have_http_status(:ok)
    comment.reload
    expect(comment.last_delivered_at).to eq Time.zone.at(1_598_494_217.5)
    expect(comment.last_delivered_successfully).to be true
    expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
  end

  it "records a failed delivery of an alert email and unsubscribes the alert" do
    alert = create(:alert, id: alert_id)
    post_event(status_event_body(event: "MessageDeliveryFailed", tag: alert_tag, status: "HardFail"))
    expect(response).to have_http_status(:ok)
    alert.reload
    expect(alert.last_delivered_at).to eq Time.zone.at(1_598_494_217.5)
    expect(alert.last_delivered_successfully).to be false
    expect(alert.unsubscribed).to be true
    expect(alert.unsubscribed_by).to eq "bounce"
  end

  it "records a bounce of an alert email and unsubscribes the alert" do
    alert = create(:alert, id: alert_id)
    post_event(bounce_event_body(tag: alert_tag))
    expect(response).to have_http_status(:ok)
    alert.reload
    expect(alert.last_delivered_at).to eq Time.zone.at(1_598_494_300.5)
    expect(alert.last_delivered_successfully).to be false
    expect(alert.unsubscribed).to be true
    expect(alert.unsubscribed_by).to eq "bounce"
  end

  it "records a held alert email without unsubscribing the alert" do
    alert = create(:alert, id: alert_id)
    post_event(status_event_body(event: "MessageHeld", tag: alert_tag, status: "Held"))
    expect(response).to have_http_status(:ok)
    alert.reload
    expect(alert.last_delivered_at).to eq Time.zone.at(1_598_494_217.5)
    expect(alert.last_delivered_successfully).to be false
    expect(alert.unsubscribed).to be false
  end

  it "records a failed delivery of a comment email and notifies slack" do
    comment = create(:comment, id: comment_id)
    post_event(status_event_body(event: "MessageDeliveryFailed", tag: comment_tag, status: "HardFail"))
    expect(response).to have_http_status(:ok)
    comment.reload
    expect(comment.last_delivered_at).to eq Time.zone.at(1_598_494_217.5)
    expect(comment.last_delivered_successfully).to be false
    expect(NotifySlackCommentDeliveryService).to have_received(:call).with(
      comment:,
      to: recipient_email,
      status: "hard_bounce",
      extended_status: "Some details 250 OK",
      email_id: message_id,
      email_url: message_url
    )
  end

  it "records a bounce of a comment email and notifies slack" do
    comment = create(:comment, id: comment_id)
    post_event(bounce_event_body(tag: comment_tag))
    expect(response).to have_http_status(:ok)
    comment.reload
    expect(comment.last_delivered_successfully).to be false
    expect(NotifySlackCommentDeliveryService).to have_received(:call).with(
      comment:,
      to: recipient_email,
      status: "hard_bounce",
      extended_status: "",
      email_id: message_id,
      email_url: message_url
    )
  end

  it "records a held comment email and notifies slack" do
    comment = create(:comment, id: comment_id)
    post_event(status_event_body(event: "MessageHeld", tag: comment_tag, status: "Held", details: "Message held", output: "held output"))
    expect(response).to have_http_status(:ok)
    comment.reload
    expect(comment.last_delivered_successfully).to be false
    expect(NotifySlackCommentDeliveryService).to have_received(:call).with(
      comment:,
      to: recipient_email,
      status: "held",
      extended_status: "Message held held output",
      email_id: message_id,
      email_url: message_url
    )
  end

  it "accepts a delayed delivery event and does nothing" do
    alert = create(:alert, id: alert_id)
    post_event(status_event_body(event: "MessageDelayed", tag: alert_tag, status: "SoftFail"))
    expect(response).to have_http_status(:ok)
    alert.reload
    expect(alert.last_delivered_at).to be_nil
    expect(alert.last_delivered_successfully).to be_nil
    expect(alert.unsubscribed).to be false
    expect(NotifySlackCommentDeliveryService).not_to have_received(:call)
  end
end
