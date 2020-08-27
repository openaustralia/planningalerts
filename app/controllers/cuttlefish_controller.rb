# frozen_string_literal: true

class CuttlefishController < ApplicationController
  # Because this is an API
  skip_before_action :verify_authenticity_token

  def event
    # First check that key is what we expect. Otherwise ignore this request
    if params[:key] != ENV["CUTTLEFISH_WEBHOOK_KEY"]
      head :forbidden
      return
    end

    if params[:delivery_event]
      # Check if this is from a comment
      comment_id = params[:delivery_event]["email"]["meta_values"]["comment-id"]
      if comment_id
        NotifySlackCommentDeliveryService.call(
          comment: Comment.find(comment_id),
          to: params[:delivery_event]["email"]["to"],
          status: params[:delivery_event]["status"],
          extended_status: params[:delivery_event]["extended_status"]
        )
      end
    end

    head :ok
  end
end
