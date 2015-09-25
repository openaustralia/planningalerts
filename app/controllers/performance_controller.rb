class PerformanceController < ApplicationController
  def index
    @comments = Comment.all if Comment.any?
  end
end
