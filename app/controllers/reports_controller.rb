class ReportsController < ApplicationController
  skip_before_filter :set_mobile_format
  skip_before_filter :force_mobile_format

  def new
    @comment = Comment.visible.find(params[:comment_id])
    @report = Report.new
  end
  
  def create
    @comment = Comment.visible.find(params[:comment_id])
    @report = @comment.reports.build(:name => params[:report][:name], :email => params[:report][:email], :details => params[:report][:details])
    if @report.save
      ReportNotifier.notify(@report).deliver
    else
      render 'new'
    end
  end
end
