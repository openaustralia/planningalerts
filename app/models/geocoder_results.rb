# frozen_string_literal: true

class GeocoderResults
  attr_reader :all, :success, :original_address

  def initialize(all, success, original_address)
    @all = all
    @success = success
    @original_address = original_address
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
