class ReportsController < ApplicationController
  def new
    @comment = Comment.visible.find(params[:comment_id])
    @report = Report.new
  end

  def create
    @comment = Comment.visible.find(params[:comment_id])
    @report = @comment.reports.build(name: params[:report][:name], email: params[:report][:email], details: params[:report][:details])

    if verify_recaptcha && @report.save
      ReportNotifier.notify(@report).deliver_later
    else
      render 'new'
    end
  end
end
