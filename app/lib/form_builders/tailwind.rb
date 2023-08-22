# typed: strict
# frozen_string_literal: true

module FormBuilders
  class Tailwind < ActionView::Helpers::FormBuilder
    extend T::Sig

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def text_field(method, options = {})
      super(method, options.merge(class: "text-2xl text-navy placeholder:text-warm-grey border-light-grey2 #{options[:class]}"))
    end
  end
end
