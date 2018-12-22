# frozen_string_literal: true

class GeocoderResults
  attr_reader :all, :success

  def initialize(all, success)
    @all = all
    @success = success
  end

  # Top location result
  def top
    all.first
  end

  # The remaining location results
  def rest
    all[1..-1]
  end
end
