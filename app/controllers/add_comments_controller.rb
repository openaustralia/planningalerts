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

    add_comment = AddComment.new(
      name: params[:add_comment][:name],
      text: params[:add_comment][:text],
      address: params[:add_comment][:address],
      email: params[:add_comment][:email],
      # TODO: Remove comment_for
      comment_for: params[:add_comment][:comment_for],
      application: @application
    )
    @add_comment = T.let(add_comment, T.nilable(AddComment))

    if IsEmailAddressBannedService.call(email: params[:add_comment][:email])
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
