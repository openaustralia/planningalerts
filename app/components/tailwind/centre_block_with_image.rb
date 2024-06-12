# typed: strict
# frozen_string_literal: true

module Tailwind
  class CentreBlockWithImage < ViewComponent::Base
    extend T::Sig

    renders_one :heading
    renders_one :image

    sig { params(extra_classes: String).void }
    def initialize(extra_classes: "")
      super

      @extra_classes = extra_classes
    end
  end
end
