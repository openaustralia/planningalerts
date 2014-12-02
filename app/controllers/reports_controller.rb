class ReportsController < ApplicationController
  def new
    @comment = Comment.visible.find(params[:comment_id])
    @report = Report.new
  end

  def create
    @comment = Comment.visible.find(params[:comment_id])

    # First check if the honeypot field has been filled out by a spam bot
    # If so, make it look like things worked but don't actually do anything
    if params[:little_sweety].blank?
      report = @comment.reports.build(:name => params[:report][:name], :email => params[:report][:email], :details => params[:report][:details])
      if report.save
        ReportNotifier.delay.notify(report)
      else
        render 'new'
      end
    end
  end
end
