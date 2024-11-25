# typed: strict
# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  extend T::Sig

  # href is untyped to support passing objects or paths or arrays to construct urls from
  sig do
    params(tag: Symbol, size: String, type: Symbol, href: T.untyped, icon: T.nilable(Symbol),
           open_in_new_tab: T::Boolean, name: T.nilable(String), disabled: T::Boolean,
           confirm: T.nilable(String)).void
  end
  def initialize(tag:, size:, type:, href: nil, icon: nil, open_in_new_tab: false, name: nil, disabled: false,
                 confirm: nil)
    super

    classes = %w[font-semibold]

    @size = T.let(size, String)

    case size
    when "lg"
      classes += %w[px-4 py-2]
    when "xl"
      classes += %w[px-10 py-3 sm:py-4]
    else
      raise "Unexpected size #{size}"
    end

    classes << text_size_class

    # TODO: Hover states are not subtle enough IMHO
    case type
    when :primary
      classes << "text-white bg-green"
      classes << "hover:bg-dark-green" unless disabled
    # Special version of a primary button that you should only use when it is on
    # a dark background (such as navy). Its default state is the same as primary but
    # it's interactive states go lighter rather than darker
    when :primary_on_dark_background
      classes << "text-white bg-green"
      classes << "hover:bg-white hover:text-green hover:ring-2 hover:ring-green" unless disabled
    when :secondary
      classes << "text-white bg-warm-grey"
      classes << "hover:bg-dark-warm-grey" unless disabled
    # This is not strictly an "inverse" but is good to be used on darker coloured backgrounds
    when :inverse
      classes << "text-white bg-navy"
      classes << "hover:text-navy hover:bg-white hover:ring-2 hover:ring-navy" unless disabled
    else
      raise "Unexpected type #{type}"
    end

    # All the buttons share the same focus styling
    classes += ["focus:outline-none", "focus:ring-4", "focus:ring-sun-yellow"]

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

    options["x-on:click"] = "if (!confirm('#{confirm}')) { $event.preventDefault(); }" if confirm

    @options = T.let(options, T.nilable(T::Hash[Symbol, T.nilable(String)]))
    @tag = tag
    @href = href
    @icon = icon
  end

  sig { returns(String) }
  def text_size_class
    case @size
    when "lg"
      "text-lg"
    when "xl"
      "text-xl"
    else
      raise "Unexpected size #{@size}"
    end
  end

  sig { params(block: T.proc.returns(String)).returns(String) }
  def wrapper_tag(&block)
    if @tag == :a
      link_to @href, @options, &block
    elsif @tag == :button
      button_tag @options, &block
    end
  end
end
