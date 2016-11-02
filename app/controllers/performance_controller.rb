class PerformanceController < ApplicationController
  def index
    @daily_comment_metrics = comment_performance_data
  end

  def alerts
    respond_to do |format|
      format.json { render json: alert_performance_data }
    end
  end

  def comments
    respond_to do |format|
      format.json { render json: comment_performance_data }
    end
  end

  private

  def alert_performance_data
    (3.months.ago.to_date..1.day.ago.to_date).to_a.reverse.map do |day|
      {
        date: day,
        new_alert_subscribers: Alert.count_of_new_unique_email_created_on_date(day),
        emails_completely_unsubscribed: Alert.count_of_email_completely_unsubscribed_on_date(day)
      }
    end
  end

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
