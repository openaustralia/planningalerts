# typed: strict
# frozen_string_literal: true

module Tailwind
  class LinkBlock < ViewComponent::Base
    extend T::Sig

    sig { params(url: String).void }
    def initialize(url:)
      super
      @url = url
    end

    # Helper that returns a span that is styled to look like a link
    # but really acts more like a header. By using this helper the caller
    # can put this anywhere inside a link block
    sig { params(text: String).returns(String) }
    def linkify(text)
      # TODO: Remove duplication between this and the link styles defined in pa_link_to
      content_tag(:span, text, class: "font-bold underline text-fuchsia group-hover:text-fuchsia-darker")
    end
  end
end
