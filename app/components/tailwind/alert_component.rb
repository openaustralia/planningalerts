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
        @bg_class = T.let("bg-lavender", String)
        @image_src = T.let("tailwind/tick.svg", String)
        @image_alt = T.let("Success", String)
      when :warning
        @bg_class = "bg-error-red"
        @image_src = "tailwind/warning.svg"
        @image_alt = "Warning"
      else
        raise "Invalid value for type: #{type}"
      end
    end
  end
end
