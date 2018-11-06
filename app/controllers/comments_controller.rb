class CommentsController < ApplicationController
  def index
    @description = "Recent comments"

    if params[:authority_id]
      authority = Authority.find_by_short_name_encoded!(params[:authority_id])
      # Unscope application order default scope so it's not by application.date_scraped
      comments_to_display = authority.comments.unscope(:order)
      @description << " on applications from #{authority.full_name_and_state}"
    else
      comments_to_display = Comment.all
    end

    @comments = comments_to_display.visible.order("confirmed_at DESC").paginate page: params[:page]
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

  def per_week
    authority = Authority.find_by_short_name_encoded!(params[:authority_id])

    respond_to do |format|
      format.json { render json: authority.comments_per_week }
    end
  end

  def writeit_reply_webhook
    if params[:message_id].nil?
      render text: "No message_id", status: 404
      return
    end

    comment = Comment.find_by(writeit_message_id: params[:message_id][%r{/api/v1/message/(\d*)/}, 1])
    if comment.nil?
      render text: "Comment not found.", status: 404
      return
    end

    comment.create_replies_from_writeit!
    render text: "Processing inbound message.", status: 200
  end
end
