class CommentsController < ApplicationController
  def create
    @application = Application.find(params[:application_id])
    # TODO: Put controls on model so that hash assignment below can't be abused
    @comment = Comment.new(params[:comment])
    @comment.application_id = @application.id
    if @comment.save
      CommentNotifier.deliver_confirm(@comment)
      redirect_to checkmail_application_comment_url(@application, @comment)
    else
      render 'applications/show'
    end
  end
  
  def checkmail
    @application = Application.find(params[:application_id])
  end
  
  def confirmed
    @comment = Comment.find_by_confirm_id(params[:id])
    if @comment
      @comment.confirmed = true
      @comment.save!
    else
      render :text => "", :status => 404
    end
  end
end
