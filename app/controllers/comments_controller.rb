# typed: strict
# frozen_string_literal: true

class CommentsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!, only: %i[create preview update destroy publish personal]
  # TODO: Add checks for all other actions on this controller
  after_action :verify_authorized, only: %i[preview update destroy publish]

  layout "profile", only: :personal

  sig { void }
  def index
    authority_id = T.cast(params[:authority_id], T.nilable(String))

    description = +"All recent comments"
    if authority_id
      authority = Authority.find_short_name_encoded!(authority_id)
      comments_to_display = authority.comments
      description << " on applications from #{authority.full_name_and_state}"
    else
      comments_to_display = Comment.all
    end
    @description = T.let(description, T.nilable(String))

    @comments = T.let(comments_to_display.published.includes(application: :authority).order("published_at DESC").page(params[:page]), T.untyped)
  end

  sig { void }
  def personal
    # We also want to include comments that have been hidden
    comments = T.must(current_user).comments.published.order(published_at: :desc).page(params[:page])
    @comments = T.let(comments, T.nilable(ActiveRecord::Relation))
  end

  sig { void }
  def create
    application = Application.find(T.cast(params[:application_id], String))
    @application = T.let(application, T.nilable(Application))

    params_comment = T.cast(params[:comment], ActionController::Parameters)

    comment = Comment.new(
      name: params_comment[:name],
      text: params_comment[:text],
      address: params_comment[:address],
      application: @application,
      user: current_user
    )
    comment.published = false
    @comment = T.let(comment, T.nilable(Comment))

    if comment.save
      redirect_to preview_comment_path(comment)
      return
    end

    # TODO: This seems to have a lot repeated from Application#show
    flash.now[:error] = t(".not_filled_out")

    # HACK: Required for new email alert signup form
    @alert = T.let(Alert.new(address: application.address, radius_meters: Alert::DEFAULT_RADIUS), T.nilable(Alert))
    @comments = T.let(application.comments.published.order(:published_at), T.untyped)

    render "applications/show"
  end

  sig { void }
  def update
    comment = Comment.find(T.cast(params[:id], String))
    authorize(comment)
    comment.update!(comment_params)
    redirect_to preview_comment_path(comment)
  end

  sig { void }
  def destroy
    comment = Comment.find(T.cast(params[:id], String))
    authorize(comment)
    comment.destroy!
    redirect_to application_path(comment.application, anchor: "add-comment")
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
    comment = Comment.find(T.cast(params[:id], String))
    authorize(comment)
    @comment = T.let(comment, T.nilable(Comment))
  end

  sig { void }
  def publish
    comment = Comment.find(T.cast(params[:id], String))
    authorize(comment)
    comment.update!(published: true, published_at: Time.current)

    comment.send_comment!
    # The flash is used to show a special alert box above the specific new comment
    # which allows the user to share it on Facebook, etc..
    redirect_to helpers.comment_path(comment), flash: { published_comment_id: comment.id }
  end

  private

  sig { returns(ActionController::Parameters) }
  def comment_params
    params.require(:comment).permit(:text, :name, :address)
  end
end
