class CommentsController < ApplicationController
  def index
    @comments = Comment.visible.order("updated_at DESC").paginate page: params[:page]
    @rss = comments_url(params.merge(format: "rss", page: nil))

    respond_to do |format|
      format.html
      format.rss
      format.js { render content_type: Mime::JSON }
    end
  end

  def confirmed
    @comment = Comment.find_by_confirm_id(params[:id])
    if @comment
      @comment.confirm!
      redirect_to @comment.application, notice: render_to_string(partial: 'confirmed').html_safe
    else
      render text: "", status: 404
    end
  end
end
