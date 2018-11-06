class AddCommentsController < ApplicationController
  respond_to :html

  def create
    @application = Application.find(params[:application_id])

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    return if params[:little_sweety].present?

    @add_comment = AddComment.new(
      add_comment_params.merge(
        application: @application,
        theme: @theme
      )
    )

    @comment = @add_comment.save_comment

    return if @comment

    # TODO: This seems to have a lot repeated from Application#show
    flash.now[:error] = "Some of the comment wasn't filled out completely. See below."

    @councillor_list_open = true if params[:councillors_list_toggler] == "open"

    @councillors = @application.councillors_available_for_contact if @theme.eql? "default"

    # HACK: Required for new email alert signup form
    @alert = Alert.new(address: @application.address)

    render 'applications/show'
  end

  private

  def add_comment_params
    params.require(:add_comment).permit(
      :name,
      :text,
      :address,
      :email,
      :theme,
      :comment_for
    )
  end
end
