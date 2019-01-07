# frozen_string_literal: true

class GeocoderResults
  attr_reader :all, :error

  def initialize(all, error)
    @all = all
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
