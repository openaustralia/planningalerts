# frozen_string_literal: true

class GeocoderResults
  attr_reader :all, :success, :error

  def initialize(all, success, error)
    @all = all
    @success = success
    @error = error
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
