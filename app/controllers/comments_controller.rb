# typed: true
# frozen_string_literal: true

class CommentsController < ApplicationController
  def index
    @description = +"Recent comments"
    authority_id = params[:authority_id]
    if authority_id
      authority = Authority.find_short_name_encoded!(authority_id)
      comments_to_display = authority.comments
      @description << " on applications from #{authority.full_name_and_state}"
    else
      comments_to_display = Comment.all
    end

    @comments = comments_to_display.confirmed.order("confirmed_at DESC").page(params[:page])
    @rss = comments_url(
      authority_id: params[:authority_id],
      format: "rss",
      page: nil
    )

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
      redirect_to @comment.application, notice: render_to_string(partial: "confirmed", locals: { comment: @comment })
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
end
