# typed: true
# frozen_string_literal: true

class ReportsController < ApplicationController
  class NewParams < T::Struct
    const :comment_id, T.nilable(Integer)
  end

  def new
    typed_params = TypedParams[NewParams].new.extract!(params)
    @comment = Comment.visible.find(typed_params.comment_id)
    @report = Report.new
  end

  class ReportParams < T::Struct
    const :name, String
    const :email, String
    const :details, String
  end

  class CreateParams < T::Struct
    const :comment_id, Integer
    const :report, ReportParams
  end

  def create
    typed_params = TypedParams[CreateParams].new.extract!(params)
    @comment = Comment.visible.find(typed_params.comment_id)
    @report = @comment.reports.build(
      name: typed_params.report.name,
      email: typed_params.report.email,
      details: typed_params.report.details
    )

    if verify_recaptcha && @report.save
      ReportMailer.notify(@report).deliver_later
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
