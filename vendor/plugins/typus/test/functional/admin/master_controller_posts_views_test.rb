require 'test/helper'

class Admin::PostsControllerTest < ActionController::TestCase

  ##
  # get :index
  ##

  def test_should_render_index_and_verify_presence_of_custom_partials
    get :index
    partials = %w( _index.html.erb _sidebar.html.erb )
    partials.each { |p| assert_match p, @response.body }
  end

  def test_should_render_index_and_verify_page_title
    get :index
    assert_select 'title', "#{Typus::Configuration.options[:app_name]} - Posts"
  end

  def test_should_render_index_and_show_add_entry_link

    get :index

    assert_select "#sidebar ul" do
      assert_select "li", "Add new"
    end

  end

  def test_should_render_index_and_not_show_add_entry_link

    typus_user = typus_users(:designer)
    @request.session[:typus_user_id] = typus_user.id

    get :index
    assert_response :success

    assert_no_match /Add new/, @response.body

  end

  def test_should_render_index_and_show_trash_item_image
    get :index
    assert_response :success
    assert_select '.trash', 'Trash'
  end

  def test_should_render_index_and_not_show_trash_image

    typus_user = typus_users(:designer)
    @request.session[:typus_user_id] = typus_user.id

    get :index
    assert_response :success
    assert_select '.trash', false

  end

  def test_should_get_index_and_render_edit_or_show_links

    %w( edit show ).each do |action|

      options = Typus::Configuration.options.merge(:default_action_on_item => action)
      Typus::Configuration.stubs(:options).returns(options)

      get :index

      Post.find(:all).each do |post|
        assert_match "/posts/#{action}/#{post.id}", @response.body
      end

    end

  end

  def test_should_get_index_and_render_edit_or_show_links_on_owned_records

    typus_user = typus_users(:editor)
    @request.session[:typus_user_id] = typus_user.id

    get :index

    Post.find(:all).each do |post|
      action = post.owned_by?(typus_user) ? 'edit' : 'show'
      assert_match "/posts/#{action}/#{post.id}", @response.body
    end

  end

  def test_should_get_index_and_render_edit_or_show_on_only_user_items

    typus_user = typus_users(:editor)
    @request.session[:typus_user_id] = typus_user.id

    %w( edit show ).each do |action|

      options = Typus::Configuration.options.merge(:only_user_items => true, 
                                                   :default_action_on_item => action)
      Typus::Configuration.stubs(:options).returns(options)

      get :index

      Post.find(:all).each do |post|
        if post.owned_by?(typus_user)
          assert_match "/posts/#{action}/#{post.id}", @response.body
        else
          assert_no_match /\/posts\/#{action}\/#{post.id}/, @response.body
        end
      end

    end

  end

  ##
  # get :new
  ##

  def test_should_render_posts_partials_on_new
    get :new
    partials = %w( _new.html.erb _sidebar.html.erb )
    partials.each { |p| assert_match p, @response.body }
  end

  def test_should_render_new_and_verify_page_title
    get :new
    assert_select 'title', "#{Typus::Configuration.options[:app_name]} - Posts &rsaquo; New"
  end

  ##
  # get :edit
  ##

  def test_should_render_edit_and_verify_presence_of_custom_partials
    get :edit, { :id => posts(:published).id }
    partials = %w( _edit.html.erb _sidebar.html.erb )
    partials.each { |p| assert_match p, @response.body }
  end

  def test_should_render_edit_and_verify_page_title
    get :edit, { :id => posts(:published).id }
    assert_select 'title', "#{Typus::Configuration.options[:app_name]} - Posts &rsaquo; Edit"
  end

  ##
  # get :show
  ##

  def test_should_render_show_and_verify_presence_of_custom_partials
    get :show, { :id => posts(:published).id }
    partials = %w( _show.html.erb _sidebar.html.erb )
    partials.each { |p| assert_match p, @response.body }
  end

  def test_should_render_show_and_verify_page_title
    get :show, { :id => posts(:published).id }
    assert_select 'title', "#{Typus::Configuration.options[:app_name]} - Posts &rsaquo; Show"
  end

  def test_should_render_show_and_verify_add_relationships_links

    ##
    # Admin
    ##

    [ posts(:owned_by_admin), posts(:owned_by_editor) ].each do |post|

      get :show, { :id => post.id }

      %w( assets categories comments views ).each do |model|
        assert_select "div##{model} h2", "#{model.capitalize}\n    Add new"
      end

    end

    ##
    # Editor
    ##

    typus_user = typus_users(:editor)
    @request.session[:typus_user_id] = typus_user.id

    get :show, { :id => posts(:owned_by_admin).id }

    # This is a has_many relationship, and record is owned by admin, so the 
    # editor can only list. Assets it's not shown because the editor doesn't 
    # have access to this resource.
    assert_select 'div#assets h2', false
    assert_select 'div#categories h2', "Categories"
    assert_select 'div#comments h2', "Comments"
    assert_select 'div#views h2', "Views"

    get :show, { :id => posts(:owned_by_editor).id }

    # This is a has_many (polimorphic) relationship, but editor can't add new items.
    assert_select 'div#assets h2', false
    # This is a has_and_belongs_to_many relationship and editor can add new items.
    assert_select 'div#categories h2', "Categories\n    Add new"
    # This is a has_many relationship, but editor can't add items.
    assert_select 'div#comments h2', "Comments"
    # This is a has_many relationship and editor can add items.
    assert_select 'div#views h2', "Views\n    Add new"

    expected = "/admin/views/new?back_to=%2Fadmin%2Fposts%2Fshow%2F4%23views&amp;post_id=4&amp;resource=post&amp;resource_id=4"
    assert_match expected, @response.body

  end

end