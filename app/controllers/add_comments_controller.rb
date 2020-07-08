# typed: true
# frozen_string_literal: true

class AddCommentsController < ApplicationController
  respond_to :html

  class AddCommentParams < T::Struct
    const :name, String
    const :text, String
    const :address, String
    const :email, String
    const :comment_for, T.nilable(String)
  end

  class CreateParams < T::Struct
    const :application_id, Integer
    const :little_sweety, T.nilable(String)
    const :add_comment, AddCommentParams
    const :councillors_list_toggler, T.nilable(String)
  end

  def create
    typed_params = TypedParams[CreateParams].new.extract!(params)
    @application = Application.find(typed_params.application_id)

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    return if typed_params.little_sweety.present?

    @add_comment = AddComment.new(
      typed_params.add_comment.serialize.merge(
        application: @application
      )
    )

    @comment = @add_comment.save_comment

    return if @comment

    # TODO: This seems to have a lot repeated from Application#show
    flash.now[:error] = t(".not_filled_out")

    @councillor_list_open = true if typed_params.councillors_list_toggler == "open"

    # HACK: Required for new email alert signup form
    @alert = Alert.new(address: @application.address)

    render "applications/show"
  end
end
