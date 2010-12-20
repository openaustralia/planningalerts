class CommentsController < ApplicationController
  def create
    @application = Application.find(params[:application_id])
    # TODO: Put controls on model so that hash assignment below can't be abused
    @comment = Comment.new(params[:comment])
    @comment.application_id = @application.id
    if @comment.save
      redirect_to checkmail_application_comment_url(@application, @comment)
    else
      render 'applications/show'
    end
  end
  
  def checkmail
    @application = Application.find(params[:application_id])
  end
end
