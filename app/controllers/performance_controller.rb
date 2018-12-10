# frozen_string_literal: true

class PerformanceController < ApplicationController
  def index
    @daily_comment_metrics = comment_performance_data
  end

  def comments
    respond_to do |format|
      format.json { render json: comment_performance_data }
    end
  end

  private

  def comment_performance_data
    (3.months.ago.to_date..1.day.ago.to_date).to_a.reverse.map do |day|
      {
        date: day,
        first_time_commenters: Comment.by_first_time_commenters_for_date(day).count,
        returning_commenters: Comment.by_returning_commenters_for_date(day).count
      }
    end
  end
end
