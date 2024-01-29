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

      classes += %w[cursor-not-allowed opacity-40] if disabled && tag == :button

      # Using inlined svg icons so that we can set their colour based on the current text colour
      case icon
      when nil
        icon_path = nil
      when :trash
        icon_path = "application/svg/trash"
      when :edit
        icon_path = "application/svg/pencil"
      when :external
        icon_path = "application/svg/external"
      when :share
        # TODO: Share icon is not visually consistent with external link icon
        icon_path = "application/svg/share"
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
      @icon_path = T.let(icon_path, T.nilable(String))
    end
  end
end
