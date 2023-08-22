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

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def text_field(method, options = {})
      super(method, options.merge(class: "text-2xl text-navy placeholder:text-warm-grey border-light-grey2 #{options[:class]}"))
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def password_field(method, options = {})
      super(method, options.merge(class: "text-2xl text-navy placeholder:text-warm-grey border-light-grey2 #{options[:class]}"))
    end
  end
end
