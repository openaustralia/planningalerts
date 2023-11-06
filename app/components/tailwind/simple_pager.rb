# typed: strict
# frozen_string_literal: true

module Tailwind
  class SimplePager < ViewComponent::Base
    extend T::Sig
    include ApplicationHelper

    sig { params(collection: T.untyped).void }
    def initialize(collection:)
      super
      @collection = collection
    end
  end
end
