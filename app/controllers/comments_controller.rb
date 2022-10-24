# typed: strict
# frozen_string_literal: true

class CommentsController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    authority_id = T.cast(params[:authority_id], T.nilable(String))

    description = +"Recent comments"
    if authority_id
      authority = Authority.find_short_name_encoded!(authority_id)
      comments_to_display = authority.comments
      description << " on applications from #{authority.full_name_and_state}"
    else
      comments_to_display = Comment.all
    end
    @description = T.let(description, T.nilable(String))

    @comments = T.let(comments_to_display.confirmed.order("confirmed_at DESC").page(params[:page]), T.untyped)
    @rss = T.let(comments_url(
                   authority_id: params[:authority_id],
                   format: "rss",
                   page: nil
                 ),
                 T.nilable(String))

    respond_to do |format|
      format.html
      format.rss
      format.js { render content_type: Mime[:json] }
    end
  end

  sig { void }
  def confirmed
    @comment = T.let(Comment.find_by(confirm_id: params[:id]), T.nilable(Comment))
    if @comment
      @comment.confirm!
      redirect_to @comment.application, notice: render_to_string(partial: "confirmed", locals: { comment: @comment })
    else
      render plain: "", status: :not_found
    end
  end

  sig { void }
  def per_week
    params_authority_id = T.cast(params[:authority_id], String)

    authority = Authority.find_short_name_encoded!(params_authority_id)

    respond_to do |format|
      format.json { render json: authority.comments_per_week }
    end
  end
end
