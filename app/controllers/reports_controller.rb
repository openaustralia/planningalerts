class ReportsController < ApplicationController
  def new
    @comment = Comment.visible.find(params[:comment_id])
    @report = Report.new
  end

  def create
    @comment = Comment.visible.find(params[:comment_id])
    @report = @comment.reports.build(name: params[:report][:name], email: params[:report][:email], details: params[:report][:details])

    if verify_recaptcha
      if @report.save
        ReportNotifier.notify(@report).deliver_later
      else
        render 'new'
      end
    else
      flash[:error] = "Sorry, we couldn't verify that you're not a robot. Make sure you click the <em>I'm not a robot</em> box below and try again.".html_safe
      render 'new'
    end
  end
end
