# typed: strict
# frozen_string_literal: true

class CommentsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!, only: %i[create preview update destroy]
  # TODO: Add checks for all other actions on this controller
  after_action :verify_authorized, only: %i[preview update destroy]

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

    @comments = T.let(comments_to_display.confirmed.includes(application: :authority).order("confirmed_at DESC").page(params[:page]), T.untyped)
  end

  sig { void }
  def create
    application = Application.find(params[:application_id])
    @application = T.let(application, T.nilable(Application))

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
    if show_tailwind_theme?
      comment.previewed = false
    else
      comment.previewed = true
      comment.previewed_at = Time.current
    end
    @comment = T.let(comment, T.nilable(Comment))

    if comment.save
      if show_tailwind_theme?
        redirect_to preview_comment_path(comment)
      else
        comment.send_comment!
        redirect_to application, notice: render_to_string(partial: "confirmed", locals: { comment: })
      end
      return
    end

    # TODO: This seems to have a lot repeated from Application#show
    flash.now[:error] = t(".not_filled_out")

    # HACK: Required for new email alert signup form
    @alert = T.let(Alert.new(address: application.address, radius_meters: Alert::DEFAULT_RADIUS), T.nilable(Alert))
    @comments = T.let(application.comments.confirmed_and_previewed.order(:confirmed_at), T.untyped)

    render "applications/show"
  end

  sig { void }
  def update
    comment = Comment.find(params[:id])
    authorize(comment)
    comment.update!(comment_params)
    redirect_to preview_comment_path(comment)
  end

  sig { void }
  def destroy
    comment = Comment.find(params[:id])
    authorize(comment)
    comment.destroy!
    redirect_to application_path(comment.application, anchor: "add-comment")
  end

  # TODO: We should leave this working until March 2023 to alllow people to still confirm old comments
  sig { void }
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

  sig { void }
  def preview
    comment = Comment.find(params[:id])
    authorize(comment)
    @comment = T.let(comment, T.nilable(Comment))
  end

  private

  sig { returns(ActionController::Parameters) }
  def comment_params
    T.cast(params.require(:comment), ActionController::Parameters).permit(:text, :name, :address)
  end
end
