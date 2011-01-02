class CommentsController < ApplicationController
  def create
    @application = Application.find(params[:application_id])
    # TODO: Put controls on model so that hash assignment below can't be abused
    @comment = Comment.new(params[:comment])
    @comment.application_id = @application.id
    if @comment.save
      CommentNotifier.deliver_confirm(@comment)
    else
      render 'applications/show'
    end
  end
  
  def confirmed
    @comment = Comment.find_by_confirm_id(params[:id])
    if @comment
      @comment.confirmed = true
      @comment.save!
      CommentNotifier.deliver_notify(@comment)
    else
      render :text => "", :status => 404
    end
  end
end
