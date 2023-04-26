# typed: strict
# frozen_string_literal: true

class CuttlefishController < ApplicationController
  extend T::Sig

  # Because this is an API
  protect_from_forgery with: :null_session

  sig { void }
  def event
    delivery_event = T.cast(params[:delivery_event], T.nilable(ActionController::Parameters))

    # First check that key is what we expect. Otherwise ignore this request
    if params[:key] != Rails.application.credentials.dig(:cuttlefish, :webhook_key)
      head :forbidden
      return
    end

    if delivery_event
      delivery_event_email = T.cast(delivery_event[:email], ActionController::Parameters)
      delivery_event_email_meta_values = T.cast(delivery_event_email[:meta_values], ActionController::Parameters)
      delivery_event_email_to = T.cast(delivery_event_email[:to], String)
      deliver_event_status = T.cast(delivery_event[:status], String)
      delivery_event_extended_status = T.cast(delivery_event[:extended_status], String)
      delivery_event_email_id = T.cast(delivery_event_email[:id], T.any(String, Numeric))

      # We're not interested in soft bounces. So, just accept them and move on...
      if deliver_event_status == "soft_bounce"
        head :ok
        return
      end
      success = deliver_event_status == "delivered"

      # Check if this is from a comment
      comment_id = delivery_event_email_meta_values["comment-id"]
      if comment_id
        comment = Comment.find(comment_id)
        comment.update!(
          last_delivered_at: delivery_event[:time],
          last_delivered_successfully: success
        )
        unless success
          NotifySlackCommentDeliveryService.call(
            comment:,
            to: delivery_event_email_to,
            status: deliver_event_status,
            extended_status: delivery_event_extended_status,
            email_id: delivery_event_email_id.to_i
          )
        end
      end

      # Check if this is from an alert
      alert_id = delivery_event_email_meta_values["alert-id"]
      if alert_id
        alert = Alert.find(alert_id)
        alert.update!(
          last_delivered_at: delivery_event[:time],
          last_delivered_successfully: success
        )
        # Check if there was a hard bounce because of a bad email address
        # If that is the case we will automatically unsubscribe them here
        alert.unsubscribe_by_bounce! if ["5.1.1", "5.1.10", "5.4.1", "5.4.4"].include?(delivery_event[:dsn])
      end
    end

    head :ok
  end
end
