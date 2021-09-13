# frozen_string_literal: true

module EnvHelpers
  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end
end
