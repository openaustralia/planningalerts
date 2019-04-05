# frozen_string_literal: true

class CommentsController < ApplicationController
  def index
    @description = +"Recent comments"

    if params[:authority_id]
      authority = Authority.find_short_name_encoded!(params[:authority_id])
      comments_to_display = authority.comments
      @description << " on applications from #{authority.full_name_and_state}"
    else
      comments_to_display = Comment.all
    end

    @comments = comments_to_display.visible.order("confirmed_at DESC").paginate page: params[:page]
    @rss = comments_url(params.permit(%i[authority_id page]).merge(format: "rss", page: nil))

    respond_to do |format|
      format.html
      format.rss
      format.js { render content_type: Mime[:json] }
    end
  end

  def confirmed
    @comment = Comment.find_by(confirm_id: params[:id])
    if @comment
      @comment.confirm!
      # rubocop:disable Rails/OutputSafety
      redirect_to @comment.application, notice: render_to_string(partial: "confirmed", locals: { comment: @comment }).html_safe
      # rubocop:enable Rails/OutputSafety
    else
      render plain: "", status: :not_found
    end
  end

  def per_week
    authority = Authority.find_short_name_encoded!(params[:authority_id])

    respond_to do |format|
      format.json { render json: authority.comments_per_week }
    end
  end

  def writeit_reply_webhook
    if params[:message_id].nil?
      render plain: "No message_id", status: :not_found
      return
    end

    comment = Comment.find_by(writeit_message_id: params[:message_id][%r{/api/v1/message/(\d*)/}, 1])
    if comment.nil?
      render plain: "Comment not found.", status: :not_found
      return
    end

    comment.create_replies_from_writeit!
    render plain: "Processing inbound message.", status: :ok
  end
end
