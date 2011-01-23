# coding: utf-8

require 'test/helper'

class Admin::SidebarHelperTest < ActiveSupport::TestCase

  include Admin::SidebarHelper

  include ActionView::Helpers::UrlHelper
  include ActionController::UrlWriter
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper

  def render(*args); args; end

  def setup
    default_url_options[:host] = 'test.host'
  end

  # TODO
  def test_actions
  end

  def test_export

    @resource = { :class => Post }

    params = { :controller => 'admin/posts', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    output = export

    expected = [ "admin/helpers/list", { :items => [ %Q[<a href="http://test.host/admin/posts?format=csv">CSV</a>], 
                                                     %Q[<a href="http://test.host/admin/posts?format=xml">XML</a>] ], 
                                         :header => "Export", 
                                         :options => { :header => "export" } } ]

    assert_equal expected, output

  end

  def test_build_typus_list_with_empty_content_and_empty_header
    output = build_typus_list([], :header => nil)
    assert output.empty?
  end

  def test_build_typus_list_with_content_and_header

    output = build_typus_list(['item1', 'item2'], :header => "Chunky Bacon")
    assert !output.empty?

    expected = [ "admin/helpers/list", { :header=>"Chunky bacon", 
                                         :options => { :header=>"Chunky Bacon" }, 
                                         :items => [ "item1", "item2" ] } ]

    assert_equal expected, output

  end

  def test_build_typus_list_with_content_without_header

    output = build_typus_list(['item1', 'item2'])
    expected = [ "admin/helpers/list", { :header => nil, 
                                         :options => {}, 
                                         :items=>["item1", "item2"] } ]
    assert_equal expected, output

  end

  def test_search

    @resource = { :class => TypusUser, :self => 'typus_users' }

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    output = search

    partial = "admin/helpers/search"
    options = { :hidden_params => [ %Q[<input id="action" name="action" type="hidden" value="index" />], 
                                    %Q[<input id="controller" name="controller" type="hidden" value="admin/typus_users" />] ], 
                :search_by => "First name, Last name, Email, and Role" }

    assert_equal [ partial, options ], output

  end

  def test_filters

    @resource = { :class => TypusUser, :self => 'typus_users' }

    @resource[:class].expects(:typus_filters).returns(Array.new)

    output = filters
    assert output.nil?

  end

  # TODO: Test filters when @resource[:class].typus_filters returns filters.
  def test_filters_with_filters
    return
  end

  # TODO
  def test_relationship_filter
    return
  end

  def test_date_filter

    @resource = { :class => TypusUser, :self => 'typus_users' }
    filter = 'created_at'

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    # With an empty request.

    request = ""
    output = date_filter(request, filter)

    partial = "admin/helpers/list"
    options = { :items => [ %Q[<a href="http://test.host/admin/typus_users?created_at=today" class="off">Today</a>], 
                            %Q[<a href="http://test.host/admin/typus_users?created_at=last_few_days" class="off">Last few days</a>], 
                            %Q[<a href="http://test.host/admin/typus_users?created_at=last_7_days" class="off">Last 7 days</a>], 
                            %Q[<a href="http://test.host/admin/typus_users?created_at=last_30_days" class="off">Last 30 days</a>] ], 
                :header => "Created at", 
                :options => { :attribute => "created_at" } }

    assert_equal [ partial, options ], output

    # With a request.

    request = "created_at=today&page=1"
    output = date_filter(request, filter)

    partial = "admin/helpers/list"
    options = { :items => [ %Q[<a href="http://test.host/admin/typus_users" class="on">Today</a>], 
                            %Q[<a href="http://test.host/admin/typus_users?created_at=last_few_days" class="off">Last few days</a>], 
                            %Q[<a href="http://test.host/admin/typus_users?created_at=last_7_days" class="off">Last 7 days</a>], 
                            %Q[<a href="http://test.host/admin/typus_users?created_at=last_30_days" class="off">Last 30 days</a>] ], 
                :header => "Created at", 
                :options => { :attribute => "created_at" } }

    assert_equal [ partial, options ], output

  end

  def test_boolean_filter

    @resource = { :class => TypusUser, :self => 'typus_users' }
    filter = 'status'

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    # Status is true

    request = "status=true&page=1"
    output = boolean_filter(request, filter)

    partial = "admin/helpers/list"
    options = { :items => [ %Q[<a href="http://test.host/admin/typus_users" class="on">Active</a>], 
                            %Q[<a href="http://test.host/admin/typus_users?status=false" class="off">Inactive</a>] ], 
                :header => "Status", 
                :options => { :attribute => "status" } }

    assert_equal [ partial, options ], output

    # Status is false

    request = "status=false&page=1"
    output = boolean_filter(request, filter)

    partial = "admin/helpers/list"
    options = { :items => [ %Q[<a href="http://test.host/admin/typus_users?status=true" class="off">Active</a>], 
                            %Q[<a href="http://test.host/admin/typus_users" class="on">Inactive</a>] ], 
                :header => "Status", 
                :options => { :attribute => "status" } }

    assert_equal [ partial, options ], output

  end

=begin

  # FIXME

  def test_string_filter_when_values_are_strings

    @resource = { :class => TypusUser, :self => 'typus_users' }
    filter = 'role'

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    # Roles is admin

    request = 'role=admin&page=1'
    # @resource[:class].expects('role').returns(['admin', 'designer', 'editor'])
    output = string_filter(request, filter)

 =begin
    expected = <<-HTML
<h2>Role</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?role=admin" class="on">Admin</a></li>
<li><a href="http://test.host/admin/typus_users?role=designer" class="off">Designer</a></li>
<li><a href="http://test.host/admin/typus_users?role=editor" class="off">Editor</a></li>
</ul>
    HTML
 =end

    partial = "admin/helpers/list"
    options = { :items => [ "<a href=\"http://test.host/admin/typus_users?role=admin\" class=\"on\">Admin</a>", 
                            "<a href=\"http://test.host/admin/typus_users?role=designer\" class=\"off\">Designer</a>", 
                            "<a href=\"http://test.host/admin/typus_users?role=editor\" class=\"off\">Editor</a>" ], 
                :header => "Role", 
                :options => { :attribute => "role" } }

    assert_equal [ partial, options ], output

    # Roles is editor

    request = 'role=editor&page=1'
    @resource[:class].expects('role').returns(['admin', 'designer', 'editor'])
    output = string_filter(request, filter)

 =begin
    expected = <<-HTML
<h2>Role</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?role=admin" class="off">Admin</a></li>
<li><a href="http://test.host/admin/typus_users?role=designer" class="off">Designer</a></li>
<li><a href="http://test.host/admin/typus_users?role=editor" class="on">Editor</a></li>
</ul>
    HTML
 =end

    partial = "admin/helpers/list"
    options = { :items => [ "<a href=\"http://test.host/admin/typus_users?role=admin\" class=\"off\">Admin</a>", 
                            "<a href=\"http://test.host/admin/typus_users?role=designer\" class=\"off\">Designer</a>", 
                            "<a href=\"http://test.host/admin/typus_users?role=editor\" class=\"on\">Editor</a>" ], 
                :header => "Role", 
                :options => { :attribute => "role" } }

    assert_equal [ partial, options ], output

  end

=end

=begin

  # FIXME

  def test_string_filter_when_values_are_arrays_of_strings

    @resource = { :class => TypusUser, :self => 'typus_users' }
    filter = 'role'

    params = { :controller => 'admin/typus_users', :action => 'index' }
    self.expects(:params).at_least_once.returns(params)

    request = 'role=admin&page=1'

 =begin

    array = [['Administrador', 'admin'], 
             ['Diseñador', 'designer'], 
             ['Editor', 'editor']]
    @resource[:class].expects('role').returns(array)

 =end

    output = string_filter(request, filter)

 =begin
    expected = <<-HTML
<h2>Role</h2>
<ul>
<li><a href="http://test.host/admin/typus_users?role=admin" class="on">Administrador</a></li>
<li><a href="http://test.host/admin/typus_users?role=designer" class="off">Diseñador</a></li>
<li><a href="http://test.host/admin/typus_users?role=editor" class="off">Editor</a></li>
</ul>
    HTML
 =end

    partial = "admin/helpers/list"
    options = { :items => [ "<a href=\"http://test.host/admin/typus_users?role=admin\" class=\"on\">Administrador</a>",
                            "<a href=\"http://test.host/admin/typus_users?role=designer\" class=\"off\">Diseñador</a>",
                            "<a href=\"http://test.host/admin/typus_users?role=editor\" class=\"off\">Editor</a>" ], 
                :header => "Role", 
                :options => { :attribute => "role" } }

    assert_equal [ partial, options ], output

  end

=end

=begin

  # FIXME

  def test_string_filter_when_empty_values

    @resource = { :class => TypusUser }
    filter = 'role'

    request = 'role=admin&page=1'
    @resource[:class].expects('role').returns([])
    output = string_filter(request, filter)
    assert output.empty?

  end

=end

end