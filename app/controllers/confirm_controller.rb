class ConfirmController < ApplicationController
  def alert
    @alert = Alert.find_by_confirm_id(params[:id])
    if @alert
      @alert.confirm!
    else
      render :text => "", :status => 404
    end
  end
  
  def comment
    @comment = Comment.find_by_confirm_id(params[:id])
    if @comment
      @comment.confirm!
    else
      render :text => "", :status => 404
    end
  end
end