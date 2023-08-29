# typed: strict
# frozen_string_literal: true

module FormBuilders
  class Tailwind < ActionView::Helpers::FormBuilder
    extend T::Sig

    sig { params(method: Symbol, text: T.any(T.nilable(String), T::Hash[Symbol, String]), options: T::Hash[Symbol, String]).returns(String) }
    def label(method, text = nil, options = {})
      if text.is_a?(Hash)
        options = options.merge(text)
        text = nil
      end
      super(method, text, options.merge(class: "font-bold text-2xl text-navy #{options[:class]}"))
    end

    # TODO: Remove the duplication in the text field methods below
    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def text_field(method, options = {})
      super(method, options.merge(class: "text-2xl text-navy placeholder:text-warm-grey placeholder-shown:truncate border-light-grey2 px-4 #{options[:class]}"))
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def password_field(method, options = {})
      super(method, options.merge(class: "text-2xl text-navy placeholder:text-warm-grey placeholder-shown:truncate border-light-grey2 px-4 #{options[:class]}"))
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def email_field(method, options = {})
      super(method, options.merge(class: "text-2xl text-navy placeholder:text-warm-grey placeholder-shown:truncate border-light-grey2 px-4 #{options[:class]}"))
    end

    sig { params(value: T.nilable(T.any(Symbol, String)), options: T::Hash[Symbol, T.any(String, Symbol)]).returns(ActionView::OutputBuffer) }
    def button(value = nil, options = {})
      # Ugly workaround because sorbet doesn't know about @template
      # Really would like the following line to just be "t = @template"
      t = instance_variable_get(:@template)
      options = { tag: :button, size: "2xl", type: :primary }.merge(options)
      t.render ::Tailwind::ButtonComponent.new(**T.unsafe(options)) do
        value
      end
    end
  end
end
