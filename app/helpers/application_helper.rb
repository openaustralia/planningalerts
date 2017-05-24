require 'rss/1.0'
require 'rss/2.0'

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def page_matches?(options)
    if options[:action].is_a?(Array)
      options[:action].any?{|a| current_page?(controller: options[:controller], action: a) }
    else
      current_page?(controller: options[:controller], action: options[:action])
    end
  end

  def li_selected(m, &block)
    content_tag(:li, capture(&block), class: ("selected" if page_matches?(m)))
  end

  def body_classes(controller_name, action_name)
    "c-#{controller_name} a-#{action_name}"
  end

  def meters_in_words(meters)
    if meters < 1000
      "#{significant_figure_remove_trailing_zero(meters, 2)} m"
    else
      "#{significant_figure_remove_trailing_zero(meters / 1000.0, 2)} km"
    end
  end

  def significant_figure_remove_trailing_zero(a, s)
    text = significant_figure(a, s).to_s
    if text [-2..-1] == ".0"
      text[0..-3]
    else
      text
    end
  end

  # Round the number a to s significant figures
  def significant_figure(a, s)
    if a > 0
      m = 10 ** (Math.log10(a).ceil - s)
      ((a.to_f / m).round * m).to_f
    elsif a < 0
      -significant_figure(-a, s)
    else
      0
    end
  end
  
  def km_in_words(km)
    meters_in_words(km * 1000)
  end
  
  def render_rss_feed
    render partial: 'shared/rss_item', collection: PlanningAlertsRSS.recent, as: :item
  end
  
  def render_twitter_feed(username)
    render partial: 'shared/tweet', collection: TwitterFeed.new(username).items, as: :item
  end

  def contributors
    [
      { name: "Roger Barnes", email_md5: "dd6c985d22e3bf6ea849e8d2e6750d76", github: 'mindsocket' },
      { name: "Sam Cavenagh", email_md5: "64afebb884d0f21f860076f4b8a92f50", github: 'o-sam-o' },
      { name: "Henare Degan", email_md5: "b30d37e67e4c4584a71d977763651513", github: 'henare' },
      { name: "Nick Evershed", email_md5: "7289b45ea6e9ac313bd4c34d7f4e461b", github: 'nickjevershed' },
      { name: "Andrew Harvey", email_md5: "7284ad488e18a2b052a9c7b8fe1e3922", github: '' },
      { name: "Mark Kinkade", email_md5: "1aac9f1adece54cc394b8cf6d8c84a1a", github: '' },
      { name: "Matthew Landauer", email_md5: "5a600494d91ea4223e7256989155f687", github: 'mlandauer' },
      { name: "Adrian Miller", email_md5: "fab3189512311073ccf49928112c98fa", github: 'peterneish' },
      { name: "Peter Neish", email_md5: "00477410c5069d49fad6eedaea32fd61", github: 'CloCkWeRX' },
      { name: "Daniel O'Connor", email_md5: "353d83d3677b142520987e1936fd093c", github: '' },
      { name: "Andrew Perry", email_md5: "7d329af0dcfe18c8797f542938286e46", github: 'jamezpolley' },
      { name: "James Polley", email_md5: "06a0058c9d6dc0eac55c3311a99beeda", github: '' },
      { name: "Alex (Maxious) Sadleir", email_md5: "5944d4aed96852cb4ce78db3d74edec", github: 'maxious' },
      { name: "Kris Splittgerber", email_md5: "d330c3271cdd9aab9e9e5c360235b6dc", github: '' },
      { name: "Adam Stiskala", email_md5: "f1b38bb55fedf270d3cd7c049176c09e", github: 'pinnableapps' },
      { name: "Katherine Szuminska", email_md5: "23d3fa4bbac53c44edef4ff672b9816a", github: '' },
      { name: "Justin Wells", email_md5: "3c1983a3371799ba1a78606dc62655db", github: '' },
      { name: "Dylan Fogarty-MacDonald", email_md5: "8bb01991a13de24d9620ad71d046301a", github: 'DylanFM' },
      { name: "Luke Bacon", email_md5: "0a705a02c7de5b135d90f7c08a343fa9", github: 'equivalentideas' },
      { name: "Peter Serwylo", email_md5: "c4b310e4388f2d02bc857d0815513f65", github: 'pserwylo' },
      { name: "Chris Nilsson", email_md5: "61aad7aa6e8cff40e22f420015d5aee9", github: 'otherchirps' },
      { name: "Emil Mikulic", email_md5: "dce73ce6fdc8f512ad557eb19e65480c", github: 'emikulic' },
      { name: "Elena Kelareva", email_md5: "6045804523b1526ff32b4fa75e9a9e01", github: '' },
      { name: "Tim Ansell", email_md5: "ddc397c8b591167f0a26cd3320aa794f", github: 'mithro' },
      { name: "Christopher Lam", email_md5: "9daa06c4242ab7dcb9868a54d38a0a16", github: '' },
      { name: "Haiming Lai", email_md5: "d91f47b3d22536bf6cc881eba6c33f60", github: '' },
      { name: "Kenneth Dinesen", email_md5: "2ec62f13a1b7bea1121acfb784233941", github: '' },
      { name: "Brian Zhang", email_md5: "dfa3cec311a6ac281bdd0f05f7b2839f", github: '' },
      { name: "Daniel Schramm", email_md5: "5ad9c348e0627c705ea2395339eb0feb", github: '' },
      { name: "Renee Wright", email_md5: "11917617eb0fe763c52889906b2a5540", github: 'rjwright' },
      { name: "Dave Slutzkin", email_md5: "b5491c409c2d00ff7590066599d264cb", github: 'daveslutzkin' },
      { name: "Hugh Stimson", email_md5: "5f970615ea543215fa783c89012a6287", github: 'hughstimson' },
      { name: "Eric Tam", email_md5: "7eac54f31e5f205964f9a306838d8899", github: '' },
      { name: "Ben M", email_md5: "a99b7918f974feb902e89bb613b32991", github: '' },
      { name: "Kelvin Nicholson", email_md5: "68993df636ccc98ae440563cf62badd5", github: 'kelvinn' },
      { name: "Jason Thomas", email_md5: "edf2f394e21a040eca21d3618a8d7032", github: 'JasonThomasData' },
      { name: "Mark Nottingham", email_md5: "38f92fdb9ac1b5213d40c595b14ec620", github: 'mnot' },
      { name: "Dave Wood", email_md5: "3c4bb2010989f6b6461cb7ffb646c486", github: 'davwood' },
      { name: "Hisayo Horie", email_md5: "4524061d35b17696f37c95c227525e58", github: 'hisayohorie' },
      { name: "Akriti Verma", email_md5: "d3c175a9561c30dfa6ea6b826d875687", github: 'akve17' }
    ]
  end

  def contributor_profile_url(contributor)
    if contributor[:github].blank?
      "https://github.com/search?utf8=%E2%9C%93&q=fullname%3A%22#{URI.encode contributor[:name]}%22&type=Users&ref=searchresults"
    else
      "https://github.com/#{contributor[:github]}"
    end
  end
end
