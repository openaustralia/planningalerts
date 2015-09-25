class PerformanceController < ApplicationController
  def index
    @comments = Comment.all
    @comments_metrics_timespan = (3.months.ago.to_date..Date.today).to_a.reverse
  end
end
