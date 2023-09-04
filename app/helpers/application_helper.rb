# typed: strict
# frozen_string_literal: true

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  extend T::Sig

  # For sorbet
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::FormHelper
  include Kernel

  sig { params(path: String, extra_classes: T::Array[Symbol], block: T.untyped).returns(T.untyped) }
  def menu_item(path, extra_classes: [], &block)
    li_selected(current_page?(path), extra_classes:) do
      link_to(capture(&block), path)
    end
  end

  sig { params(selected: T::Boolean, extra_classes: T::Array[Symbol], block: T.untyped).returns(T.untyped) }
  def li_selected(selected, extra_classes: [], &block)
    content_tag(:li, capture(&block), class: extra_classes + (selected ? [:selected] : []))
  end

  sig { params(url: String, block: T.untyped).returns(T.untyped) }
  def nav_item(url, &block)
    active = current_page?(url)
    body = capture(&block)
    body += content_tag(:span, "(current)", class: "sr-only") if active
    content_tag(:li, link_to(body, url, class: "nav-link"),
                class: ["nav-item", ("active" if active)])
  end

  sig { params(meters: T.any(Float, Integer)).returns(String) }
  def meters_in_words(meters)
    if meters < 1000
      pluralize(significant_figure_remove_trailing_zero(meters.to_f, 2), "metre")
    else
      pluralize(significant_figure_remove_trailing_zero(meters / 1000.0, 2), "kilometre")
    end
  end

  sig { params(value: Float, sig_figs: Integer).returns(T.untyped) }
  def significant_figure_remove_trailing_zero(value, sig_figs)
    text = significant_figure(value, sig_figs).to_s
    if text[-2..] == ".0"
      text[0..-3]
    else
      text
    end
  end

  # Round the number a to s significant figures
  sig { params(value: Float, sig_figs: Integer).returns(Float) }
  def significant_figure(value, sig_figs)
    if value.positive?
      a = Math.log10(value).ceil - sig_figs
      if a.negative?
        m = T.cast(10**-a, Integer)
        (value.to_f * m).round.to_f / m
      else
        m = T.cast(10**a, Integer)
        (value.to_f / m).round.to_f * m
      end
    elsif value.negative?
      -significant_figure(-value, sig_figs)
    else
      0.0
    end
  end

  sig { params(value_in_km: Float).returns(String) }
  def km_in_words(value_in_km)
    meters_in_words(value_in_km * 1000)
  end

  # For some particular number of days return a human readable version
  sig { params(days: Integer).returns(String) }
  def days_in_words(days)
    case days
    when 365 / 4
      "3 months"
    when 365 / 2
      "6 months"
    when 365
      "year"
    when 365 * 2
      "2 years"
    when 365 * 5
      "5 years"
    when 365 * 10
      "10 years"
    else
      raise "Unexpected number of days"
    end
  end

  sig { returns(T::Array[T::Hash[Symbol, String]]) }
  def contributors
    JSON.parse(File.read("CONTRIBUTORS.json"), symbolize_names: true)
  end

  sig { params(contributor: T::Hash[Symbol, String]).returns(String) }
  def contributor_profile_url(contributor)
    if contributor[:github].blank?
      params = {
        q: "fullname:\"#{contributor[:name]}\"",
        type: "Users"
      }
      "https://github.com/search?#{params.to_query}"
    else
      "https://github.com/#{contributor[:github]}"
    end
  end

  sig { params(html: String).returns(String) }
  def our_sanitize(html)
    # Using sanitize gem here because it also adds rel="nofollow" to links automatically
    # which reduces "SEO" spam
    cleaned = Sanitize.clean(html, Sanitize::Config::BASIC)
    # We're trusting that the sanitize library does the right thing here. We
    # kind of have to. It's returning some allowed html. So, we have to mark
    # it as safe
    # rubocop:disable Rails/OutputSafety
    cleaned.html_safe
    # rubocop:enable Rails/OutputSafety
  end

  sig { params(params: T::Hash[Symbol, String]).returns(String) }
  def facebook_share_url(params)
    "https://www.facebook.com/sharer/sharer.php?#{params.to_query}"
  end

  sig { params(params: T::Hash[Symbol, String]).returns(String) }
  def twitter_share_url(params)
    "https://twitter.com/intent/tweet?#{params.to_query}"
  end

  sig { returns(String) }
  def donate_url
    "https://www.oaf.org.au/donate/planningalerts/"
  end

  sig { params(name: String, path: T.untyped, options: T::Hash[Symbol, String]).returns(String) }
  def pa_button_to(name, path, options = {})
    form_with(
      url: url_for(path),
      builder: FormBuilders::Tailwind,
      class: options.delete(:form_class),
      method: options.delete(:method),
      data: options.delete(:data)
    ) do |f|
      f.button name, options
    end
  end
end
