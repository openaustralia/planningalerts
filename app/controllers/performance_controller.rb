class PerformanceController < ApplicationController
  def index
    @daily_comment_metrics = comment_performance_data
  end

  private

  def comment_performance_data
    (3.months.ago.to_date..Date.today).to_a.reverse.map do |day|
      {
        date: day,
        first_time_commenters: Comment.by_first_time_commenters_for_date(day).count,
        returning_commenters: Comment.by_returning_commenters_for_date(day).count
      }
    end
  end
end
