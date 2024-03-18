# typed: strict
# frozen_string_literal: true

module Tailwind
  class Icon < ViewComponent::Base
    extend T::Sig

    sig { params(name: Symbol).void }
    def initialize(name:)
      super
      @name = name
    end
  end
end
