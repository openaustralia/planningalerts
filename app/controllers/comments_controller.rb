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
  def create
    application = Application.find(params[:application_id])
    @application = T.let(application, T.nilable(Application))

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    return if params[:little_sweety].present?

    comment_params = T.cast(params[:comment], ActionController::Parameters)

    comment = Comment.new(
      name: comment_params[:name],
      text: comment_params[:text],
      address: comment_params[:address],
      email: comment_params[:email],
      application: @application
    )
    @comment = T.let(comment, T.nilable(Comment))

    if IsEmailAddressBannedService.call(email: T.cast(comment_params[:email], String))
      flash.now[:error] = "Your email address is not allowed. Please contact us if you think this is in error."
      # HACK: Required for new email alert signup form
      @alert = T.let(Alert.new(address: application.address), T.nilable(Alert))
      render "applications/show"
      return
    end

    return if comment.save

    # TODO: This seems to have a lot repeated from Application#show
    flash.now[:error] = t(".not_filled_out")

    # HACK: Required for new email alert signup form
    @alert = T.let(Alert.new(address: application.address), T.nilable(Alert))

    render "applications/show"
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
