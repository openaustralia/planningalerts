# typed: strict
# frozen_string_literal: true

class AddCommentsController < ApplicationController
  extend T::Sig

  respond_to :html

  sig { void }
  def create
    application = Application.find(params[:application_id])
    @application = T.let(application, T.nilable(Application))

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    return if params[:little_sweety].present?

    add_comment_params = T.cast(params[:add_comment], ActionController::Parameters)

    add_comment = AddComment.new(
      name: add_comment_params[:name],
      text: add_comment_params[:text],
      address: add_comment_params[:address],
      email: add_comment_params[:email],
      # TODO: Remove comment_for
      comment_for: add_comment_params[:comment_for],
      application: @application
    )
    @add_comment = T.let(add_comment, T.nilable(AddComment))

    if IsEmailAddressBannedService.call(email: T.cast(add_comment_params[:email], String))
      flash.now[:error] = "Your email address is not allowed. Please contact us if you think this is in error."
      # HACK: Required for new email alert signup form
      @alert = T.let(Alert.new(address: application.address), T.nilable(Alert))
      render "applications/show"
      return
    end

    @comment = T.let(add_comment.save_comment, T.nilable(Comment))

    return if @comment

    # TODO: This seems to have a lot repeated from Application#show
    flash.now[:error] = t(".not_filled_out")

    # HACK: Required for new email alert signup form
    @alert = T.let(Alert.new(address: application.address), T.nilable(Alert))

    render "applications/show"
  end
end
