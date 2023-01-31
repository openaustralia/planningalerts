# typed: strict
# frozen_string_literal: true

class CommentsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!, only: :create

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
  end

  sig { void }
  def create
    application = Application.find(params[:application_id])
    @application = T.let(application, T.nilable(Application))

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    # TODO: Do we still need this given that we now require a login?
    return if params[:little_sweety].present?

    params_comment = T.cast(params[:comment], ActionController::Parameters)

    comment = Comment.new(
      name: params_comment[:name],
      text: params_comment[:text],
      address: params_comment[:address],
      application: @application,
      user: current_user,
      # Because we're logged in we don't need to go through the whole email confirmation step
      confirmed: true,
      confirmed_at: Time.current
    )
    @comment = T.let(comment, T.nilable(Comment))

    if comment.save
      comment.send_comment!
      redirect_to application, notice: render_to_string(partial: "confirmed", locals: { comment: })
      return
    end

    # TODO: This seems to have a lot repeated from Application#show
    flash.now[:error] = t(".not_filled_out")

    # HACK: Required for new email alert signup form
    @alert = T.let(Alert.new(address: application.address), T.nilable(Alert))

    render "applications/show"
  end

  sig { void }
  # TODO: We should leave this working until March 2023 to alllow people to still confirm old comments
  def confirmed
    @comment = T.let(Comment.find_by(confirm_id: params[:id]), T.nilable(Comment))
    if @comment
      @comment.confirm!

      # Confirm the attached user if it isn't already confirmed
      user = @comment.user
      user.confirm if user && !user.confirmed?

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
