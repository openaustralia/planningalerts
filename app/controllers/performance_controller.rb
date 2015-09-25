class PerformanceController < ApplicationController
  def index
    @comments = Comment.all if Comment.any?
    @comments_metrics_timespan = (3.months.ago.to_date..Date.today).to_a.reverse
  end
end
