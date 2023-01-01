# typed: strict
# frozen_string_literal: true

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  extend T::Sig

  # For sorbet
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper

  sig { params(options: T::Hash[Symbol, T.untyped]).returns(T::Boolean) }
  def page_matches?(options)
    if options[:action].is_a?(Array)
      options[:action].any? { |a| current_page?(controller: options[:controller], action: a) }
    else
      current_page?(controller: options[:controller], action: options[:action])
    end
  end

  sig { params(options: T::Hash[Symbol, T.untyped], block: T.untyped).returns(T.untyped) }
  def li_selected(options, &block)
    content_tag(:li, capture(&block), class: ("selected" if page_matches?(options)))
  end

  sig { params(url: String, block: T.untyped).returns(T.untyped) }
  def nav_item(url, &block)
    active = current_page?(url)
    body = capture(&block)
    body += content_tag(:span, "(current)", class: "sr-only") if active
    content_tag(:li, link_to(body, url, class: "nav-link"),
                class: ["nav-item", ("active" if active)])
  end

  sig { params(meters: Float).returns(String) }
  def meters_in_words(meters)
    if meters < 1000
      pluralize(significant_figure_remove_trailing_zero(meters, 2), "metre")
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

  sig { returns(T::Array[T::Hash[Symbol, String]]) }
  def contributors
    # Keeping all the names in alphabetical order by first name just so it's easier
    # to find people and it's less likely that we'll have accidental duplicates
    [
      { name: "Adam Stiskala", email_md5: "f1b38bb55fedf270d3cd7c049176c09e", github: "pinnableapps" },
      { name: "Adrian Miller", email_md5: "fab3189512311073ccf49928112c98fa", github: "" },
      { name: "Akriti Verma", email_md5: "d3c175a9561c30dfa6ea6b826d875687", github: "akve17" },
      { name: "Alex (Maxious) Sadleir", email_md5: "5944d4aed96852cb4ce78db3d74edec", github: "maxious" },
      { name: "Andrew Harvey", email_md5: "7284ad488e18a2b052a9c7b8fe1e3922", github: "andrewharvey" },
      { name: "Andrew Perry", email_md5: "7d329af0dcfe18c8797f542938286e46", github: "andrewperry" },
      { name: "Ben M", email_md5: "a99b7918f974feb902e89bb613b32991", github: "" },
      { name: "Billy Kwong", email_md5: "03eb32103050cf6fbb3de5a30f52f98d", github: "tuppa" },
      { name: "Brian Zhang", email_md5: "dfa3cec311a6ac281bdd0f05f7b2839f", github: "" },
      { name: "Chris Nilsson", email_md5: "61aad7aa6e8cff40e22f420015d5aee9", github: "otherchirps" },
      { name: "Christopher Lam", email_md5: "9daa06c4242ab7dcb9868a54d38a0a16", github: "" },
      { name: "Daniel O'Connor", email_md5: "353d83d3677b142520987e1936fd093c", github: "CloCkWeRX" },
      { name: "Daniel Schramm", email_md5: "5ad9c348e0627c705ea2395339eb0feb", github: "dpschramm" },
      { name: "Dave Slutzkin", email_md5: "b5491c409c2d00ff7590066599d264cb", github: "daveslutzkin" },
      { name: "Dave Wood", email_md5: "3c4bb2010989f6b6461cb7ffb646c486", github: "davwood" },
      { name: "Dylan Fogarty-MacDonald", email_md5: "8bb01991a13de24d9620ad71d046301a", github: "DylanFM" },
      { name: "Elena Kelareva", email_md5: "6045804523b1526ff32b4fa75e9a9e01", github: "" },
      { name: "Emil Mikulic", email_md5: "dce73ce6fdc8f512ad557eb19e65480c", github: "emikulic" },
      { name: "Eric Tam", email_md5: "7eac54f31e5f205964f9a306838d8899", github: "LoveMyData" },
      { name: "Haiming Lai", email_md5: "d91f47b3d22536bf6cc881eba6c33f60", github: "" },
      { name: "Henare Degan", email_md5: "b30d37e67e4c4584a71d977763651513", github: "henare" },
      { name: "Hisayo Horie", email_md5: "4524061d35b17696f37c95c227525e58", github: "hisayohorie" },
      { name: "Hugh Stimson", email_md5: "5f970615ea543215fa783c89012a6287", github: "hughstimson" },
      { name: "James Polley", email_md5: "06a0058c9d6dc0eac55c3311a99beeda", github: "jamezpolley" },
      { name: "Jason Thomas", email_md5: "edf2f394e21a040eca21d3618a8d7032", github: "JasonThomasData" },
      { name: "Justin Wells", email_md5: "3c1983a3371799ba1a78606dc62655db", github: "" },
      { name: "Katherine Szuminska", email_md5: "23d3fa4bbac53c44edef4ff672b9816a", github: "katska" },
      { name: "Kelvin Nicholson", email_md5: "68993df636ccc98ae440563cf62badd5", github: "kelvinn" },
      { name: "Kenneth Dinesen", email_md5: "2ec62f13a1b7bea1121acfb784233941", github: "" },
      { name: "Kris Gesling", email_md5: "a4ec899a9651f56a6aad76e2876b435e", github: "krisgesling" },
      { name: "Kris Splittgerber", email_md5: "d330c3271cdd9aab9e9e5c360235b6dc", github: "" },
      { name: "Luke Bacon", email_md5: "0a705a02c7de5b135d90f7c08a343fa9", github: "equivalentideas" },
      { name: "Mark Kinkade", email_md5: "1aac9f1adece54cc394b8cf6d8c84a1a", github: "" },
      { name: "Mark Nottingham", email_md5: "38f92fdb9ac1b5213d40c595b14ec620", github: "mnot" },
      { name: "Matthew Landauer", email_md5: "5a600494d91ea4223e7256989155f687", github: "mlandauer" },
      { name: "Nick Evershed", email_md5: "7289b45ea6e9ac313bd4c34d7f4e461b", github: "nickjevershed" },
      { name: "Peter Neish", email_md5: "00477410c5069d49fad6eedaea32fd61", github: "peterneish" },
      { name: "Peter Serwylo", email_md5: "c4b310e4388f2d02bc857d0815513f65", github: "pserwylo" },
      { name: "Renee Wright", email_md5: "11917617eb0fe763c52889906b2a5540", github: "rjwright" },
      { name: "Roger Barnes", email_md5: "dd6c985d22e3bf6ea849e8d2e6750d76", github: "mindsocket" },
      { name: "Sam Cavenagh", email_md5: "64afebb884d0f21f860076f4b8a92f50", github: "o-sam-o" },
      { name: "Tim Ansell", email_md5: "ddc397c8b591167f0a26cd3320aa794f", github: "mithro" }
    ]
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
end
