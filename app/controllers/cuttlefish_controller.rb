# typed: true
# frozen_string_literal: true

class CuttlefishController < ApplicationController
  # Because this is an API
  skip_before_action :verify_authenticity_token

  class EmailParams < T::Struct
    const :id, Integer
    const :message_id, String
    const :from, String
    const :to, String
    const :subject, String
    const :created_at, Time
    const :meta_values, T::Hash[String, String]
  end

  class DeliveryEventParams < T::Struct
    const :time, Time
    const :dsn, String
    # It looks like the sorbet-coerce gem https://github.com/chanzuckerberg/sorbet-coerce
    # doesn't yet support enums so we have to use a string for status
    const :status, String
    const :extended_status, String
    const :email, EmailParams
  end

  class TestEventParams < T::Struct
  end

  class EventParams < T::Struct
    const :key, String
    const :delivery_event, T.nilable(DeliveryEventParams)
    const :test_event, T.nilable(TestEventParams)
  end

  def event
    typed_params = TypedParams[EventParams].new.extract!(params)

    # First check that key is what we expect. Otherwise ignore this request
    if typed_params.key != ENV["CUTTLEFISH_WEBHOOK_KEY"]
      head :forbidden
      return
    end

    delivery_event = typed_params.delivery_event
    if delivery_event
      status = delivery_event.status

      # Check if this is from a comment
      comment_id = delivery_event.email.meta_values["comment-id"]
      if comment_id
        comment = Comment.find(comment_id)
        if %w[hard_bounce soft_bounce].include?(status)
          NotifySlackCommentDeliveryService.call(
            comment: comment,
            to: delivery_event.email.to,
            status: status,
            extended_status: delivery_event.extended_status,
            email_id: delivery_event.email.id
          )
        end
        if %w[delivered hard_bounce].include?(status)
          comment.update!(
            last_delivered_at: delivery_event.time,
            last_delivered_succesfully: (status == "delivered")
          )
        end
      end

      # Check if this is from an alert
      alert_id = delivery_event.email.meta_values["alert-id"]
      # Ignore soft bounces here
      if alert_id && %w[delivered hard_bounce].include?(status)
        alert = Alert.find(alert_id)
        # This will show a soft bounce as a failed delivery. Do we want this?
        # Or do we want to wait until a soft bounce turns to a hard bounce to
        # consider it a failed delivery?
        alert.update!(
          last_delivered_at: delivery_event.time,
          last_delivered_succesfully: (status == "delivered")
        )
      end
    end

    head :ok
  end
end
