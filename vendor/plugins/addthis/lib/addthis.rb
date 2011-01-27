module Jaap3
  module Addthis
    CONFIG = {:publisher => ""}
    DEFAULT_OPTIONS = {
      :script_src => "http://s7.addthis.com/js/200/addthis_widget.js",
      :brand => nil, :header_color => nil, :header_background => nil,
      :offset_top => nil, :offset_left => nil, :hover_delay => nil,
      :options => nil, :language => nil, :secure => false
    }
    BOOKMARK_BUTTON_DEFAULTS = {
      :title => "",
      :button_html => '<img src="http://s7.addthis.com/static/btn/lg-bookmark-en.gif" width="125" height="16" border="0" alt="Bookmark and Share" />'
    }
    SHARE_BUTTON_DEFAULTS = {
      :title => "",
      :button_html => '<img src="http://s7.addthis.com/static/btn/lg-share-en.gif" width="125" height="16" border="0" alt="Bookmark and Share" />'
    }
    FEED_BUTTON_DEFAULTS = {
      :title => "Subscribe using any feed reader!",
      :button_html => '<img src="http://s7.addthis.com/static/btn/lg-feed-en.gif" width="125" height="16" border="0" alt="Subscribe" />'
    }
    EMAIL_BUTTON_DEFAULTS = {
      :title => "",
      :button_html => '<img src="http://s7.addthis.com/button1-email.gif" width="54" height="16" border="0" alt="Email" />'
    }

    module Helper
      %w(bookmark share).each do |func|
        module_eval <<-EOS
          def addthis_#{func}_button(*args)
            url, options = extract_addthis_url_and_options(args)
            options[:button_html] = yield if block_given?
            options = Jaap3::Addthis::#{func.upcase}_BUTTON_DEFAULTS.merge(options)
            s = %Q(<a href="http://www.addthis.com/bookmark.php?v=20" onmouseover="\#{addthis_open("", url, options[:page_title])}" onmouseout="addthis_close()" onclick="return addthis_sendto()" title="\#{options[:title]}">)
            addthis_tag(s, options)
          end
        EOS
      end

      def addthis_email_button(*args)
        url, options = extract_addthis_url_and_options(args)
        options[:button_html] = yield if block_given?
        options = EMAIL_BUTTON_DEFAULTS.merge(options)
        s = %Q{<a href="http://www.addthis.com/bookmark.php" onclick="#{addthis_open("email", url, options[:page_title])}" title="#{options[:title]}">}
        addthis_tag(s, options)
      end

      def addthis_feed_button(url, *args)
        options = FEED_BUTTON_DEFAULTS.merge(extract_addthis_options(args))
        options[:button_html] = yield if block_given?
        s = %Q{<a href="http://www.addthis.com/feed.php?pub=#{options[:publisher]}&h1=#{url.gsub(/[^a-zA-Z0-9_\.\-]/n) {|c| sprintf('%%%02x', c[0]) }}&t1=" onclick="#{addthis_open("feed", url)}" title="#{options[:title]}" target="_blank">}
        addthis_tag(s, options)
      end

      protected
      def addthis_tag(str, options = {})
        s = ["<!-- AddThis Button BEGIN -->"]
        s << addthis_custom_script(options)
        s << "#{str}#{options[:button_html]}</a><script type=\"text/javascript\" src=\"#{options[:script_src]}\"></script>"
        s << "<!-- AddThis Button END -->"
        s = s * "\n"
        options[:secure] ? s.gsub(/http:\/\/s[57]\.addthis\.com/, "https://secure.addthis.com") : s
      end

      def addthis_custom_script(options = {})
        s = "<script type=\"text/javascript\">var addthis_pub = '#{options[:publisher]}';"
        [:brand, :header_color, :header_background, :offset_top, :offset_left, :hover_delay, :options, :language].each do |custom|
          s << "var addthis_#{custom} = #{options[custom].is_a?(Integer) ? options[custom] : "'#{options[custom]}'"};" unless options[custom].nil?
        end
        s << "</script>"
      end

      def addthis_open(type, url, title = nil)
        "return addthis_open(this, '#{type}', '#{url}'#{ title.nil? ? "" : ", '#{title.gsub("'", "\\u0027").gsub("\"", "\\u0022")}'"})"
      end

      def extract_addthis_url_and_options(args, options = {:page_title => "[TITLE]"})
        url = args[0].is_a?(String) ? args.shift : "[URL]"
        return url, options = extract_addthis_options(args, options)
      end

      def extract_addthis_options(args, options = {})
        page_title = args[0].is_a?(String) ? args.shift : options[:page_title]
        options = args[0].is_a?(Hash) ? args.shift : options
        options.symbolize_keys! if options.respond_to?(:symbolize_keys!)
        options[:page_title] = page_title
        options = CONFIG.merge(DEFAULT_OPTIONS).merge(options)
        return options
      end
    end
  end
end