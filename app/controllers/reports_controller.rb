# typed: strict
# frozen_string_literal: true

class ReportsController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!

  sig { void }
  def new
    @comment = T.let(Comment.visible.find(T.cast(params[:comment_id], String)), T.nilable(Comment))
    @report = T.let(Report.new, T.nilable(Report))
  end

  sig { void }
  def create
    params_report = T.cast(params[:report], ActionController::Parameters)

    @comment = Comment.visible.find(T.cast(params[:comment_id], String))
    @report = @comment.reports.build(
      name: T.must(current_user).name,
      email: T.must(current_user).email,
      user: current_user,
      details: params_report[:details]
    )

    if @report.save
      SupportMailer.report(@report).deliver_later
      redirect_to thank_you_comment_reports_url(@comment)
    else
      render "new"
    end
  end

  sig { void }
  def thank_you
    @comment = Comment.visible.find(T.cast(params[:comment_id], String))
  end
end
