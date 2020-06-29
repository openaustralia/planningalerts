# typed: false
# frozen_string_literal: true

class ApplicationService
  def self.call(*params)
    new(*params).call
  end
end
