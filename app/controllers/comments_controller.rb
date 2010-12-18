class CommentsController < ApplicationController
  def create
    @application = Application.find(params[:application_id])
    # TODO: Put controls on model so that hash assignment below can't be abused
    @comment = @application.comments.build(params[:comment])
    if @comment.save
      redirect_to @application
    end
  end
end
