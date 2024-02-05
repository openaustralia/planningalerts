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
      super(method, text, options.merge(class: "#{label_style(method)} #{options[:class]}"))
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def text_field(method, options = {})
      wrap_field(method, super(method, options.merge(class: "#{text_like_field_style(method)} #{options[:class]}")))
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def text_area(method, options = {})
      wrap_field(method, super(method, options.merge(class: "#{text_like_field_style(method)} #{options[:class]}")))
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def password_field(method, options = {})
      wrap_field(method, super(method, options.merge(class: "#{text_like_field_style(method)} #{options[:class]}")))
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def email_field(method, options = {})
      wrap_field(method, super(method, options.merge(class: "#{text_like_field_style(method)} #{options[:class]}")))
    end

    sig { params(value: T.nilable(T.any(Symbol, String)), options: T::Hash[Symbol, T.any(String, Symbol)]).returns(ActionView::OutputBuffer) }
    def button(value = nil, options = {})
      options = { tag: :button, size: "2xl", type: :primary }.merge(options)
      template.render ::Tailwind::ButtonComponent.new(**T.unsafe(options)) do
        value
      end
    end

    # TODO: Use better types for choices
    sig { params(method: Symbol, choices: T.untyped, options: T::Hash[Symbol, String], html_options: T::Hash[Symbol, String]).returns(String) }
    def select(method, choices = nil, options = {}, html_options = {})
      super(method, choices, options, html_options.merge(class: "#{select_style} #{html_options[:class]}"))
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def error(method, options = {})
      return "" unless object.errors.key?(method)

      m = "#{object.errors.messages_for(method).join('. ')}."
      template.content_tag(:p, m, options.merge(class: "text-2xl text-error-red #{options[:class]}"))
    end

    sig { params(text_or_options: T.untyped, options: T::Hash[Symbol, String], block: T.untyped).returns(String) }
    def hint(text_or_options = nil, options = {}, &block)
      if block_given?
        template.content_tag(:p, (text_or_options || {}).merge(class: "text-base italic text-warm-grey #{options[:class]}"), &block)
      else
        template.content_tag(:p, text_or_options, options.merge(class: "text-base italic text-warm-grey #{options[:class]}"))
      end
    end

    sig { params(method: Symbol, options: T::Hash[Symbol, String]).returns(String) }
    def street_address_field(method, options = {})
      options = {
        placeholder: "e.g. 1 Sowerby St, Goulburn, NSW 2580",
        "x-data" => "{ async initAutocomplete() {
                         const { Autocomplete } = await google.maps.importLibrary('places');
                         new Autocomplete($el, {componentRestrictions: {country: 'au'}, types: ['address']})}
                     }",
        "x-init" => "initAutocomplete()"
      }.merge(options)
      text_field(method, options)
    end

    private

    # Wraps a text field (or email or password field) in an extra div so that we can show the little error cross icon on the right
    sig { params(method: Symbol, field: String).returns(String) }
    def wrap_field(method, field)
      if error?(method)
        template.content_tag(
          :div,
          field +
            template.content_tag(
              :div,
              template.image_tag("tailwind/error-cross.svg", "aria-hidden": true),
              class: "absolute inset-y-0 flex items-center pointer-events-none right-4"
            ),
          class: "relative"
        )
      else
        field
      end
    end

    sig { params(method: Symbol).returns(String) }
    def label_style(method)
      style = +"font-bold text-2xl"
      style << " "
      style << (error?(method) ? "text-error-red" : "text-navy")
      style
    end

    sig { params(method: Symbol).returns(String) }
    def text_like_field_style(method)
      style = +"text-2xl text-navy placeholder:text-warm-grey placeholder-shown:truncate py-3 focus:ring-4 focus:ring-sun-yellow"
      style << " "
      style << (error?(method) ? "border-error-red pl-4 pr-16" : "border-light-grey2 px-4")
      style
    end

    # TODO: Handle error conditions
    sig { returns(String) }
    def select_style
      "text-2xl text-navy border-light-grey2 py-4"
    end

    sig { params(method: Symbol).returns(T::Boolean) }
    def error?(method)
      object.errors[method].any?
    end

    # Ugly workarounds because sorbet doesn't know about @object and @template
    sig { returns(T.untyped) }
    def object
      instance_variable_get(:@object)
    end

    sig { returns(T.untyped) }
    def template
      instance_variable_get(:@template)
    end
  end
end
