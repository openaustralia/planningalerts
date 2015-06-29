class CommentsController < ApplicationController
  # Allows access to /comments.js
  # TODO: Switch to .json
  skip_before_action :verify_authenticity_token, only: [:index]

  def index
    @comments = Comment.visible.order("updated_at DESC").paginate :page => params[:page]
    @rss = comments_url(params.merge(:format => "rss", :page => nil))
  end

  def create
    @application = Application.find(params[:application_id])

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    if params[:little_sweety].blank?
      # TODO: Put controls on model so that hash assignment below can't be abused
      @comment = Comment.new(params[:comment])
      @comment.application_id = @application.id
      if !@comment.save
        flash.now[:error] = "Some of the comment wasn't filled out completely. See below."
        # HACK: Required for new email alert signup form
        @alert = Alert.new(:address => @application.address)
        render 'applications/show'
      end
    end
  end

  def confirmed
    @comment = Comment.find_by_confirm_id(params[:id])
    if @comment
      @comment.confirm!
      redirect_to @comment.application, :notice => render_to_string(:partial => 'confirmed').html_safe
    else
      render :text => "", :status => 404
    end
  end
end
