require 'test/helper'

class TypusHelperTest < ActiveSupport::TestCase

  include TypusHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TextHelper
  include ActionController::UrlWriter

  def render(*args); args; end

  # FIXME: Pending to verify the applications included. Use the keys.
  def test_applications

    @current_user = typus_users(:admin)

    output = applications

    partial = "admin/helpers/applications"
    options = { :applications => { [ "Blog", [ "Comment", "Post" ] ]=> nil, 
                                   [ "Site", [ "Asset", "Page" ] ] => nil, 
                                   [ "System", [ "Delayed::Task" ] ] => nil, 
                                   [ "Typus", [ "TypusUser" ] ] => nil } }

    assert_equal partial, output.first
    # assert_equal options, output.last

  end

  # FIXME: Pending to add the options.
  def test_resources

    @current_user = typus_users(:admin)

    output = resources
    partial = "admin/helpers/resources"
    options = {}

    assert_equal partial, output.first
    # assert_equal options, output.last

  end

  def test_typus_block_when_partial_does_not_exist
    output = typus_block(:resource => 'posts', :location => 'sidebar', :partial => 'pum')
    assert output.nil?
  end

  def test_page_title
    params = {}
    options = { :app_name => 'whatistypus.com' }
    Typus::Configuration.stubs(:options).returns(options)
    output = page_title('custom_action')
    assert_equal 'whatistypus.com - Custom action', output
  end

  def test_header_with_root_path

    # Add root named route
    ActionController::Routing::Routes.add_named_route :root, "/", { :controller => "posts" }

    # ActionView::Helpers::UrlHelper does not support strings, which are returned by named routes
    # link root_path
    self.stubs(:link_to).returns(%(<a href="/">View site</a>))
    self.stubs(:link_to_unless_current).returns(%(<a href="/admin/dashboard">Dashboard</a>))

    output = header

=begin
    expected = <<-HTML
<h1>#{Typus::Configuration.options[:app_name]}</h1>
<ul>
<li><a href="/admin/dashboard">Dashboard</a></li>
<li><a href="/admin/dashboard">Dashboard</a></li>
<li><a href="/">View site</a></li>
</ul>
    HTML
=end

    partial = "admin/helpers/header"
    options = { :links => [ "<a href=\"/admin/dashboard\">Dashboard</a>",
                            "<a href=\"/admin/dashboard\">Dashboard</a>", 
                            "<a href=\"/\">View site</a>" ] }

    assert_equal [ partial, options ], output

  end

  # TODO: Clean
  def test_header_without_root_path

    # Remove root route from list
    ActionController::Routing::Routes.named_routes.routes.reject! { |key, route| key == :root }

    self.stubs(:link_to_unless_current).returns(%(<a href="/admin/dashboard">Dashboard</a>))

=begin
    expected = <<-HTML
<h1>#{Typus::Configuration.options[:app_name]}</h1>
<ul>
<li><a href="/admin/dashboard">Dashboard</a></li>
<li><a href="/admin/dashboard">Dashboard</a></li>
</ul>
    HTML
=end

    output = header
    partial = "admin/helpers/header"
    options = { :links => [ "<a href=\"/admin/dashboard\">Dashboard</a>",
                            "<a href=\"/admin/dashboard\">Dashboard</a>" ] }

    assert_equal [ partial, options ], output

  end

  def test_display_flash_message

    message = { :test => 'This is the message.' }

    output = display_flash_message(message)

=begin
    expected = <<-HTML
<div id="flash" class="test">
  <p>This is the message.</p>
</div>
    HTML
=end

    partial = "admin/helpers/flash_message"
    options = { :flash_type => :test, 
                :message => { :test => 'This is the message.' } }

    assert_equal [ partial, options ], output

  end

  def test_display_flash_message_with_empty_message
    message = {}
    output = display_flash_message(message)
    assert output.nil?
  end

end