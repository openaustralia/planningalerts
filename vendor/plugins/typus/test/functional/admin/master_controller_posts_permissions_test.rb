require 'test/helper'

class Admin::PostsControllerTest < ActionController::TestCase

  def setup_for_no_root
    @typus_user = typus_users(:editor)
    @request.session[:typus_user_id] = @typus_user.id
    assert @typus_user.is_not_root?
  end

  ##
  # Tests around what happens with records with typus_user_id when editing 
  # and showing.
  ##

  def test_should_verify_root_can_edit_any_record

    assert @typus_user.is_root?

    Post.find(:all).each do |post|
      get :edit, { :id => post.id }
      assert_response :success
      assert_template 'edit'
    end

  end

  def test_should_verify_editor_can_show_any_record

    setup_for_no_root

    Post.find(:all).each do |post|
      get :show, { :id => post.id }
      assert_response :success
      assert_template 'show'
    end

  end

  def test_should_verify_editor_can_not_edit_all_records

    setup_for_no_root

    # Editor tries to edit a post owned by hiself.
    post = posts(:owned_by_editor)
    get :edit, { :id => post.id }
    assert_response :success

    # Editor tries to edit a post owned by the admin.
    @request.env['HTTP_REFERER'] = '/admin/posts'
    post = posts(:owned_by_admin)
    get :edit, { :id => post.id }
    assert_response :redirect
    assert_redirected_to @request.env['HTTP_REFERER']
    assert_equal "You don't have permission to access this item.", flash[:notice]

    # Editor tries to show a post owned by the admin.
    post = posts(:owned_by_admin)
    get :show, { :id => post.id }
    assert_response :success
    assert_template 'show'

    # Editor tries to show a post owned by the admin.
    options = Typus::Configuration.options.merge(:only_user_items => true)
    Typus::Configuration.stubs(:options).returns(options)
    post = posts(:owned_by_admin)
    get :show, { :id => post.id }
    assert_response :redirect
    assert_redirected_to @request.env['HTTP_REFERER']

  end

  ##
  # Tests around what happens with the typus_user_id when creating items.
  ##

  def test_should_verify_typus_user_id_of_item_when_creating_record

    setup_for_no_root

    post :create, { :post => { :title => "Chunky Bacon", :body => "Lorem ipsum ..." } }
    post_ = Post.find_by_title("Chunky Bacon")

    assert_equal @request.session[:typus_user_id], post_.typus_user_id

  end

  ##
  # Tests around what happens with the typus_user_id when updating items.
  ##

  def test_should_verify_admin_updating_an_item_does_not_change_typus_user_id_if_not_defined

    assert @typus_user.is_root?

    post_ = posts(:owned_by_editor)
    post :update, { :id => post_.id, :post => { :title => 'Updated by admin' } }
    post_updated = Post.find(post_.id)
    assert_equal post_.typus_user_id, post_updated.typus_user_id

  end

  def test_should_verify_admin_updating_an_item_does_change_typus_user_id_to_whatever_admin_wants

    assert @typus_user.is_root?

    post_ = posts(:owned_by_editor)
    post :update, { :id => post_.id, :post => { :title => 'Updated', :typus_user_id => 108 } }
    post_updated = Post.find(post_.id)
    assert_equal 108, post_updated.typus_user_id

  end

  def test_should_verify_editor_updating_an_item_does_not_change_typus_user_id

    setup_for_no_root

    [ 108, nil ].each do |typus_user_id|
      post_ = posts(:owned_by_editor)
      post :update, { :id => post_.id, :post => { :title => 'Updated', :typus_user_id => typus_user_id } }
      post_updated = Post.find(post_.id)
      assert_equal  @request.session[:typus_user_id], post_updated.typus_user_id
    end

  end

end