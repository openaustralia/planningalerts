class CommentsController < ApplicationController
  def create
    @application = Application.find(params[:application_id])
    # TODO: Put controls on model so that hash assignment below can't be abused
    @comment = Comment.new(params[:comment])
    @comment.application_id = @application.id
    if !@comment.save
      flash.now[:error] = "Some of the comment wasn't filled out completely. See below."
      render 'applications/show'
    end
  end
end
