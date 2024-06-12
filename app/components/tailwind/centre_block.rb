# typed: strict
# frozen_string_literal: true

module Tailwind
  class CentreBlock < ViewComponent::Base
    extend T::Sig

    sig { params(extra_classes: String).void }
    def initialize(extra_classes: "")
      super

      @extra_classes = extra_classes
    end
  end
end
