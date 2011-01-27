require 'test_helper'
include Jaap3::Addthis::Helper

class AddthisTest < Test::Unit::TestCase

  should "provide addthis_bookmark_button" do
    assert respond_to?(:addthis_bookmark_button)
  end

  should "alias addthis_bookmark_button as addthis_share_button" do
    assert respond_to?(:addthis_share_button)
  end

  should "provide addthis_feed_button" do
    assert respond_to?(:addthis_feed_button)
  end

  should "provide addthis_email_button" do
    assert respond_to?(:addthis_email_button)
  end

  [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
    context "the output of #{m}" do
      setup do
        @output = method(m).call("http://example.com")
        @output_lines = @output.split("\n")
      end

      should_set_script_src_to Jaap3::Addthis::DEFAULT_OPTIONS[:script_src]
      
      [:brand, :header_color, :header_background,
       :offset_top, :offset_left, :hover_delay].each do |attribute|
        should_not_customize attribute
      end

      should "start with an html comment" do
        assert_equal "<!-- AddThis Button BEGIN -->", @output_lines.first
      end

      should "end with an html comment" do
        assert_equal "<!-- AddThis Button END -->", @output_lines.last
      end
    end
  end

  [:addthis_bookmark_button, :addthis_share_button, :addthis_email_button].each do |m|
    context "the output of #{m} with url and title set" do
      setup { @output = method(m).call("http://example.com", "It's an \"example\"") }

      should "include title" do
        assert_match "'It\\u0027s an \\u0022example\\u0022'", @output
      end
    end
  end

  context "a bookmark button" do
    setup { @output = addthis_bookmark_button }

    should_set_title_to Jaap3::Addthis::BOOKMARK_BUTTON_DEFAULTS[:title]
    should_set_href_to "http://www.addthis.com/bookmark.php?v=20"

    should "set url to [URL]" do
      assert_match "'[URL]'", @output
    end

    should "set title to [TITLE]" do
      assert_match "'[TITLE]'", @output
    end

    should "set button html to default" do
      assert_match Jaap3::Addthis::BOOKMARK_BUTTON_DEFAULTS[:button_html], @output
    end
  end

  context "a share button" do
    setup { @output = addthis_share_button }

    should_set_title_to Jaap3::Addthis::SHARE_BUTTON_DEFAULTS[:title]
    should_set_href_to "http://www.addthis.com/bookmark.php?v=20"

    should "set url to [URL]" do
      assert_match "'[URL]'", @output
    end

    should "set title to [TITLE]" do
      assert_match "'[TITLE]'", @output
    end

    should "set button html to default" do
      assert_match Jaap3::Addthis::SHARE_BUTTON_DEFAULTS[:button_html], @output
    end
  end

  context "a feed button" do
    setup { @output = addthis_feed_button("http://example.com") }

    should_set_title_to Jaap3::Addthis::FEED_BUTTON_DEFAULTS[:title]
    should_set_href_to "http://www.addthis.com/feed.php?pub=&h1=http%3a%2f%2fexample.com&t1="

    should "set url to example.com" do
      assert_match "'http://example.com')", @output
    end

    should "set button html to default" do
      assert_match Jaap3::Addthis::FEED_BUTTON_DEFAULTS[:button_html], @output
    end
  end

  context "an email button" do
    setup { @output = addthis_email_button }

    should_set_title_to Jaap3::Addthis::EMAIL_BUTTON_DEFAULTS[:title]
    should_set_href_to "http://www.addthis.com/bookmark.php"

    should "set button html to default" do
      assert_match Jaap3::Addthis::EMAIL_BUTTON_DEFAULTS[:button_html], @output
    end
  end

  context "with publisher configured" do
    setup do
      @config = Jaap3::Addthis::CONFIG.clone
      Jaap3::Addthis::CONFIG[:publisher] = "test_publisher"
    end
    
    teardown { Jaap3::Addthis::CONFIG.clear.merge! @config }

    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "the output of #{m}" do
        setup { @output = method(m).call("http://example.com") }

        should_customize :pub, "test_publisher"
      end
    end

    context "a feed button" do
      setup { @output = addthis_feed_button("http://example.com") }

      should_set_href_to "http://www.addthis.com/feed.php?pub=test_publisher&h1=http%3a%2f%2fexample.com&t1="
    end

    context "in turn overwritten by options hash" do
      [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
        context "the output of #{m}" do
          setup { @output = method(m).call("http://example.com", :publisher => "another_publisher") }

          should_customize :pub, "another_publisher"
        end
      end

      context "a feed button" do
        setup { @output = addthis_feed_button("http://example.com", :publisher => "another_publisher") }

        should_set_href_to "http://www.addthis.com/feed.php?pub=another_publisher&h1=http%3a%2f%2fexample.com&t1="
      end
    end
  end

  context "with altered script_src" do
    setup do
      @defaults = Jaap3::Addthis::DEFAULT_OPTIONS.clone
      Jaap3::Addthis::DEFAULT_OPTIONS[:script_src] = "http://example.com/example.js"
    end

    teardown { Jaap3::Addthis::DEFAULT_OPTIONS.clear.merge! @defaults }

    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "the output of #{m}" do
        setup { @output = method(m).call("http://example.com") }

        should_set_script_src_to "http://example.com/example.js"
      end
    end

    context "in turn overwritten by options hash" do
      [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
        context "the output of #{m}" do
          setup { @output = method(m).call("http://example.com", :script_src => "http://www.example.com/example.js") }

          should_set_script_src_to "http://www.example.com/example.js"
        end
      end
    end
  end

  context "when overwriting title" do
    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "the output of #{m}" do
        setup { @output = method(m).call("http://example.com", :title => "Example title") }

        should_set_title_to "Example title"
      end
    end
  end

  context "when setting secure to true" do
    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "by using the options hash the output of #{m}" do
        setup { @output = method(m).call("http://example.com", :secure => true) }

        should_set_script_src_to "https://secure.addthis.com/js/200/addthis_widget.js"
      end
    end

    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "by altering the defaults the output of #{m}" do
        setup do
          @defaults = Jaap3::Addthis::DEFAULT_OPTIONS.clone
          Jaap3::Addthis::DEFAULT_OPTIONS[:secure] = true
          @output = method(m).call("http://example.com")
        end

        teardown { Jaap3::Addthis::DEFAULT_OPTIONS.clear.merge! @defaults }

        should_set_script_src_to "https://secure.addthis.com/js/200/addthis_widget.js"
      end
    end
  end

  context "with a block" do
    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "the output of #{m}" do
        setup do
          @output = method(m).call("http://example.com") do
            "Click here to AddThis"
          end
        end

        should "contain the custom text" do
          assert_match(/<a[^>]+>Click here to AddThis<\/a>/, @output)
        end
      end
    end
  end

  context "with changed default html" do
    setup do
      @bookmark_defaults = Jaap3::Addthis::BOOKMARK_BUTTON_DEFAULTS.clone
      Jaap3::Addthis::BOOKMARK_BUTTON_DEFAULTS[:button_html] = "Click here to AddThis"
      @share_defaults = Jaap3::Addthis::SHARE_BUTTON_DEFAULTS.clone
      Jaap3::Addthis::SHARE_BUTTON_DEFAULTS[:button_html] = "Click here to AddThis"
      @feed_defaults = Jaap3::Addthis::FEED_BUTTON_DEFAULTS.clone
      Jaap3::Addthis::FEED_BUTTON_DEFAULTS[:button_html] = "Click here to AddThis"
      @email_defaults = Jaap3::Addthis::FEED_BUTTON_DEFAULTS.clone
      Jaap3::Addthis::EMAIL_BUTTON_DEFAULTS[:button_html] = "Click here to AddThis"
    end

    teardown do
      Jaap3::Addthis::BOOKMARK_BUTTON_DEFAULTS.clear.merge! @bookmark_defaults
      Jaap3::Addthis::SHARE_BUTTON_DEFAULTS.clear.merge! @share_defaults
      Jaap3::Addthis::FEED_BUTTON_DEFAULTS.clear.merge! @feed_defaults
      Jaap3::Addthis::EMAIL_BUTTON_DEFAULTS.clear.merge! @email_defaults
    end

    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "the output of #{m}" do
        setup { @output = method(m).call("http://example.com") }

        should "contain the custom text" do
          assert_match(/<a[^>]+>Click here to AddThis<\/a>/, @output)
        end
      end
    end
  end

  context "tricked out with options" do
    options = {
      :brand => "Example brand",
      :header_color => "white",
      :header_background => "black",
      :offset_top => 40,
      :offset_left => 60,
      :hover_delay => 200
    }
    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "the output of #{m}" do
        setup { @output = method(m).call("http://example.com", options) }

        options.each_pair do |attribute, value|
          should_customize attribute, value
        end
      end
    end

    [:addthis_bookmark_button, :addthis_share_button, :addthis_feed_button, :addthis_email_button].each do |m|
      context "by changing the defaults the output of #{m}" do
        setup do
          options.each_pair do |attribute, value|
            @defaults = Jaap3::Addthis::DEFAULT_OPTIONS.clone
            Jaap3::Addthis::DEFAULT_OPTIONS[attribute] = value
          end
          @output = method(m).call("http://example.com")
        end

        teardown { Jaap3::Addthis::DEFAULT_OPTIONS.clear.merge! @defaults }

        options.each_pair do |attribute, value|
          should_customize attribute, value
        end
      end
    end
  end

  context "with a custom list of services" do
    context "the output of addthis_bookmark_button" do
      setup { @output = addthis_bookmark_button(:options => "facebook, email, twitter, more") }

      should_customize :options, "facebook, email, twitter, more"
    end

    context "by changing the defaults the output of addthis_bookmark_button" do
      setup do
        @defaults = Jaap3::Addthis::DEFAULT_OPTIONS.clone
        Jaap3::Addthis::DEFAULT_OPTIONS[:options] = "facebook, email, twitter, more"
        @output = addthis_bookmark_button
      end

      teardown { Jaap3::Addthis::DEFAULT_OPTIONS.clear.merge! @defaults }

      should_customize :options, "facebook, email, twitter, more"
    end
  end

  context "with a custom language set" do
    setup { @output = addthis_bookmark_button(:language => "nl") }
    
    should_customize :language, "nl"
  end

end