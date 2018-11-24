# frozen_string_literal: true

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
      if flash[:recaptcha_error]
        # Safe html i18n not working in controllers.
        # See https://github.com/rails/rails/issues/27862
        # rubocop:disable Rails/OutputSafety
        flash[:error] = t(".you_are_a_robot_html").html_safe
        # rubocop:enable Rails/OutputSafety
      end
      render "new"
    end
  end
end
