# typed: strict
# frozen_string_literal: true

module Tailwind
  class ShareButton < ViewComponent::Base
    extend T::Sig

    sig { params(url: String).void }
    def initialize(url:)
      super
      @url = url
    end
  end
end
