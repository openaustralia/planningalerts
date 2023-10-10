# typed: strict
# frozen_string_literal: true

module Tailwind
  class ButtonComponent < ViewComponent::Base
    extend T::Sig

    # href is untyped to support passing objects or paths or arrays to construct urls from
    sig { params(tag: Symbol, size: String, type: Symbol, href: T.untyped, icon: T.nilable(Symbol), open_in_new_tab: T::Boolean).void }
    def initialize(tag:, size:, type:, href: nil, icon: nil, open_in_new_tab: false)
      super

      classes = %w[font-semibold]

      case size
      when "lg"
        classes += %w[px-4 py-2 text-lg]
      when "2xl"
        classes += %w[px-10 py-3 sm:py-4 text-2xl]
      else
        raise "Unexpected size #{size}"
      end

      case type
      when :primary
        classes << "text-white bg-green"
      when :secondary
        classes << "text-white bg-warm-grey"
      # This is not strictly an "inverse" but is good to be used on darker coloured backgrounds
      when :inverse
        classes << "text-white bg-navy"
      # TODO: Don't like that we have two "inverse" types
      when :inverse_primary
        classes << "text-green bg-white border-2"
      else
        raise "Unexpected type #{type}"
      end

      case icon
      when nil
        icon_path = nil
      when :trash
        icon_path = "tailwind/trash.svg"
        icon_alt = "Trash icon"
      when :edit
        icon_path = "tailwind/pencil.svg"
        icon_alt = "Pencil icon"
      when :external
        icon_path = "tailwind/external.svg"
        icon_alt = "External link icon"
      when :share
        # TODO: Share icon is not visually consistent with external link icon
        icon_path = "tailwind/share.svg"
        icon_alt = "Share icon"
      else
        raise "Unexpected icon #{icon}"
      end

      case tag
      when :a
        raise "href not set" if href.nil?

        classes << "inline-block"
        options = { class: classes }
        if open_in_new_tab
          options[:target] = "_blank"
          options[:rel] = "noopener"
        end
      when :button
        # TODO: I really don't think we want 'name: nil' in general
        options = { name: nil, class: classes }
        raise "open_in_new_tab only makes sense when using a tag" if open_in_new_tab
      else
        raise "Unexpected tag: #{tag}"
      end

      @options = T.let(options, T.nilable(T::Hash[Symbol, T.nilable(String)]))
      @tag = tag
      @href = href
      @icon_path = T.let(icon_path, T.nilable(String))
      @icon_alt = T.let(icon_alt, T.nilable(String))
    end
  end
end
