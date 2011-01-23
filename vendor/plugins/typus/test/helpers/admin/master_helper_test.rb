require 'test/helper'

class Admin::MasterHelperTest < ActiveSupport::TestCase

  include Admin::MasterHelper

  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper

  def render(*args); args; end

  def test_display_link_to_previous

    @resource = { :class => Post, :human_name => 'Post' }
    params = { :action => 'edit', :back_to => '/back_to_param' }
    self.expects(:params).at_least_once.returns(params)

    output = display_link_to_previous

=begin
    expected = <<-HTML
<div id="flash" class="notice">
  <p>You're updating a Post. <a href="/back_to_param">Do you want to cancel it?</a></p>
</div>
    HTML
=end

    partial = "admin/helpers/display_link_to_previous"
    options = { :message => "You're updating a Post." }

    assert_equal [ partial, options ], output

  end

  def test_remove_filter_link
    output = remove_filter_link('')
    assert output.nil?
  end

  def test_build_list_when_returns_a_typus_table

    model = TypusUser
    fields = [ 'email', 'role', 'status' ]
    items = TypusUser.find(:all)
    resource = 'typus_users'

    self.stubs(:build_typus_table).returns('a_list_with_items')

    output = build_list(model, fields, items, resource)
    expected = 'a_list_with_items'

    assert_equal expected, output

  end

  def test_build_list_when_returns_a_template

    model = TypusUser
    fields = [ 'email', 'role', 'status' ]
    items = TypusUser.find(:all)
    resource = 'typus_users'

    self.stubs(:render).returns('a_template')
    File.stubs(:exist?).returns(true)

    output = build_list(model, fields, items, resource)
    expected = 'a_template'

    assert_equal expected, output

  end

end