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

    @comments = comments_to_display.visible.order("updated_at DESC").paginate page: params[:page]
    @rss = comments_url(params.merge(format: "rss", page: nil))

    respond_to do |format|
      format.html
      format.rss
      format.js { render content_type: Mime::JSON }
    end
  end

  def create
    @application = Application.find(params[:application_id])

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    if params[:little_sweety].blank?
      @comment = Comment.new(comment_params)
      @comment.application_id = @application.id
      if !@comment.save
        flash.now[:error] = "Some of the comment wasn't filled out completely. See below."
        # HACK: Required for new email alert signup form
        @alert = Alert.new(address: @application.address)
        render 'applications/show'
      end
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

  def test_form
    @application = Application.find(params[:application_id])
    redirect_to application_path(@application, with_councillors: true),
                notice: render_to_string(partial: 'test_form_thanks').html_safe
  end

  private

  def comment_params
    params.require(:comment).permit(:text, :name, :email, :address)
  end
end
