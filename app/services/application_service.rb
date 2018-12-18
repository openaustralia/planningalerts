# frozen_string_literal: true

class ApplicationService
  def self.call(options)
    new(options).call
  end
end
