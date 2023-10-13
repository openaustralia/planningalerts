# typed: strict
# frozen_string_literal: true

module Tailwind
  extend T::Sig
  class AlertComponent < ViewComponent::Base
    extend T::Sig

    sig { params(type: T.anything).void }
    def initialize(type:)
      super

      case type
      when :success
        @bg_colour = T.let("lavender", String)
        @image_src = T.let("tailwind/tick.svg", String)
        @image_alt = T.let("Tick", String)
      when :warning
        @bg_colour = "error-red"
        @image_src = "tailwind/warning.svg"
        @image_alt = "Warning sign"
      else
        raise "Invalid value for type: #{type}"
      end
    end
  end
end
