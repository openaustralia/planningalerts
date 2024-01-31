# typed: strict
# frozen_string_literal: true

module Tailwind
  class ButtonComponent < ViewComponent::Base
    extend T::Sig

    # href is untyped to support passing objects or paths or arrays to construct urls from
    sig do
      params(tag: Symbol, size: String, type: Symbol, href: T.untyped, icon: T.nilable(Symbol),
             open_in_new_tab: T::Boolean, name: T.nilable(String), disabled: T::Boolean).void
    end
    def initialize(tag:, size:, type:, href: nil, icon: nil, open_in_new_tab: false, name: nil, disabled: false)
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

      # TODO: Hover states are not subtle enough IMHO
      case type
      when :primary
        classes << "text-white bg-green hover:bg-dark-green active:ring-4 ring-sun-yellow"
      # Special version of a primary button that you should only use when it is on
      # a dark background (such as navy). Its default state is the same as primary but
      # it's interactive states go lighter rather than darker
      when :primary_on_dark_background
        classes << "text-white bg-green hover:bg-white hover:text-green hover:ring-2 hover:ring-green active:ring-4 active:ring-sun-yellow"
      when :secondary
        classes << "text-white bg-warm-grey hover:bg-dark-warm-grey active:ring-4 ring-sun-yellow"
      # This is not strictly an "inverse" but is good to be used on darker coloured backgrounds
      when :inverse
        classes << "text-white bg-navy hover:text-navy hover:bg-white hover:ring-2 hover:ring-navy active:ring-4 active:ring-sun-yellow"
      # TODO: Don't like that we have three "inverse" types!
      # TODO: Need interactive states for inverse_primary and inverse_lavender
      when :inverse_primary
        classes << "text-green bg-white border-2"
      when :inverse_lavender
        classes << "text-lavender bg-white"
      else
        raise "Unexpected type #{type}"
      end

      classes += %w[cursor-not-allowed opacity-40] if disabled && tag == :button

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
        options = { name:, class: classes }
        raise "open_in_new_tab only makes sense when using a tag" if open_in_new_tab
      else
        raise "Unexpected tag: #{tag}"
      end

      raise "Can't use disabled with a link at the moment" if disabled && tag == :a

      options[:disabled] = true if disabled

      @options = T.let(options, T.nilable(T::Hash[Symbol, T.nilable(String)]))
      @tag = tag
      @href = href
      @icon = icon
    end
  end
end
