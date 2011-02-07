class ReportsController < ApplicationController
  def new
    @comment = Comment.find(params[:comment_id])
    @report = Report.new
  end
  
  def create
    @comment = Comment.find(params[:comment_id])
    @report = @comment.reports.build(:name => params[:report][:name], :email => params[:report][:email], :details => params[:report][:details])
    unless @report.save
      render 'new'
    end
  end
end
