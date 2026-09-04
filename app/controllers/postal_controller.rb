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
    failure_status = signature_failure_status(raw_post)
    if failure_status
      head failure_status
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
    else
      # Unreachable while the regex above only matches these two prefixes.
      # Kept so that adding a prefix without a branch fails loudly.
      raise ArgumentError, "Unexpected tag prefix #{match[1]}"
    end

    head :ok
  end

  private

  # The X-Postal-Signature-256 header holds a Base64 encoded RSA-SHA256 signature of the raw
  # JSON request body, made with postal's installation wide signing key. We check it against
  # every signing key postal is currently publishing, so a rotation on the postal server needs
  # no change here. Postal also sends X-Postal-Signature, an RSA-SHA1 signature of the same body
  # that its own source marks as being for legacy use, and X-Postal-Signature-KID naming the
  # key it used. We ignore both.
  # See https://docs.postalserver.io/developer/webhooks
  #
  # Returns nil when the request is properly signed, otherwise the status to respond with. A
  # signature that doesn't check out gets 403 and the event is gone for good. Not being able to
  # reach the published keys is a different thing: we can't tell whether the request is genuine,
  # so 503 asks postal to retry, which it does over about 36 minutes, rather than silently
  # dropping a real delivery event.
  sig { params(raw_post: String).returns(T.nilable(Symbol)) }
  def signature_failure_status(raw_post)
    signature = T.cast(request.headers["X-Postal-Signature-256"], T.nilable(String))
    # Checked before the keys are fetched, so an unsigned request costs us no outbound request
    return :forbidden if signature.nil?

    keys = PostalSigningKeysService.call
    return :service_unavailable if keys.nil?

    digest = OpenSSL::Digest.new("SHA256")
    decoded_signature = Base64.decode64(signature)
    return nil if keys.any? { |key| key.verify(digest, decoded_signature, raw_post) }

    :forbidden
  end
end
