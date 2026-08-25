# typed: strict
# frozen_string_literal: true

class PostalController < ApplicationController
  extend T::Sig

  # Because this is an API
  skip_before_action :verify_authenticity_token

  STATUS_EVENTS = T.let(%w[MessageSent MessageDeliveryFailed MessageHeld MessageBounced].freeze, T::Array[String])

  sig { void }
  def event
    # Verify the signature against the raw body before trusting anything in it
    raw_post = request.raw_post
    unless valid_signature?(raw_post)
      head :forbidden
      return
    end

    body = T.cast(JSON.parse(raw_post), T::Hash[String, T.untyped])
    event = T.cast(body["event"], T.nilable(String))
    payload = T.cast(body["payload"], T.nilable(T::Hash[String, T.untyped]))

    # We're not interested in temporary failures. Postal keeps retrying and
    # tells us how it went in a later webhook. So, just accept and move on...
    # Any event type we don't know about is also accepted and ignored.
    if event.nil? || STATUS_EVENTS.exclude?(event) || payload.nil?
      head :ok
      return
    end

    # MessageBounced events wrap the message that bounced in original_message
    message_key = event == "MessageBounced" ? "original_message" : "message"
    message = T.cast(payload[message_key], T.nilable(T::Hash[String, T.untyped]))
    tag = T.cast(message&.fetch("tag", nil), T.nilable(String))
    match = tag&.match(/\A(alert|comment)-(\d+)\z/)
    if message.nil? || match.nil?
      # Not an email that we tagged. Nothing to do.
      head :ok
      return
    end

    # Status event payloads carry a float epoch timestamp. MessageBounced
    # payloads don't, so fall back to the webhook's own timestamp.
    time = Time.zone.at(T.cast(payload["timestamp"] || body["timestamp"], Numeric).to_f)
    success = event == "MessageSent"

    id = T.must(match[2]).to_i
    case match[1]
    when "alert"
      alert = Alert.find(id)
      alert.update!(
        last_delivered_at: time,
        last_delivered_successfully: success
      )
      # Postal only sends these events for permanent failures so we can
      # unsubscribe straight away without needing to inspect a DSN code.
      # Held messages are deliberately not treated as bounces.
      alert.unsubscribe_by_bounce! if %w[MessageDeliveryFailed MessageBounced].include?(event)
    when "comment"
      comment = Comment.find(id)
      comment.update!(
        last_delivered_at: time,
        last_delivered_successfully: success
      )
      unless success
        details = T.cast(payload["details"], T.nilable(String))
        output = T.cast(payload["output"], T.nilable(String))
        message_id = T.cast(message["id"], T.any(String, Numeric))
        NotifySlackCommentDeliveryService.call(
          comment:,
          to: T.cast(message["to"], String),
          status: event == "MessageHeld" ? "held" : "hard_bounce",
          extended_status: [details, output].compact.join(" "),
          email_id: message_id.to_i,
          email_url: "https://postal.oaf.org.au/org/oaf/servers/planningalerts-comments/messages/#{message_id}"
        )
      end
    end

    head :ok
  end

  private

  # Postal signs each webhook request with the server's signing key. The
  # X-Postal-Signature header contains a Base64 encoded RSA-SHA1 signature
  # of the raw JSON request body and we hold the matching public key in the
  # Rails credentials. See https://docs.postalserver.io/developer/webhooks
  # The header name and digest are per the postal v3 docs and are kept in
  # this one method so they're trivially adjustable during integration
  # testing.
  sig { params(raw_post: String).returns(T::Boolean) }
  def valid_signature?(raw_post)
    public_key_pem = T.cast(Rails.application.credentials.dig(:postal, :webhook_public_key), T.nilable(String))
    return false if public_key_pem.nil?

    signature = T.cast(request.headers["X-Postal-Signature"], T.nilable(String))
    return false if signature.nil?

    public_key = OpenSSL::PKey::RSA.new(public_key_pem)
    public_key.verify(OpenSSL::Digest.new("SHA1"), Base64.decode64(signature), raw_post)
  end
end
