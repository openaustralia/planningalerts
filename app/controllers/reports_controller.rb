# typed: true
# frozen_string_literal: true

class ReportsController < ApplicationController
  def new
    # typed_params = TypedParams[NewParams].new.extract!(params)
    @comment = Comment.visible.find(params[:comment_id])
    @report = Report.new
  end

  def create
    # typed_params = TypedParams[CreateParams].new.extract!(params)
    @comment = Comment.visible.find(params[:comment_id])
    @report = @comment.reports.build(
      name: params[:report][:name],
      email: params[:report][:email],
      details: params[:report][:details]
    )

    if verify_recaptcha && @report.save
      ReportMailer.notify(@report).deliver_later
    else
      flash[:error] = t(".you_are_a_robot_html") if flash[:recaptcha_error]
      render "new"
    end
  end
end
