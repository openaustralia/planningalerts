# typed: true
# frozen_string_literal: true

class ApplicationService
  def initialize(_params); end

  def self.call(params)
    new(params).call
  end
end
