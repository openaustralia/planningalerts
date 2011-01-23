require 'test/helper'

class Admin::PostsControllerTest < ActionController::TestCase

  ##
  # Actions related to index.
  ##

  def test_should_index_items
    get :index
    assert_response :success
    assert_template 'index'
  end

  ##
  # Actions related to new.
  ##

  def test_should_new_an_item
    get :new
    assert_response :success
    assert_template 'new'
  end

  ##
  # Actions related to create.
  ##

  def test_should_create_an_item

    assert_difference 'Post.count' do
      post :create, { :post => { :title => 'This is another title', :body => 'Body' } }
      assert_response :redirect
      assert_redirected_to :controller => 'admin/posts', :action => 'edit', :id => Post.last
    end

  end

  def test_should_create_an_item_and_redirect_to_index

    options = Typus::Configuration.options.merge(:index_after_save => true)
    Typus::Configuration.stubs(:options).returns(options)

    assert_difference 'Post.count' do
      post :create, { :post => { :title => 'This is another title', :body => 'Body' } }
      assert_response :redirect
      assert_redirected_to :action => 'index'
    end

  end

  ##
  # Actions related to show.
  ##

  def test_should_show_an_item
    post_ = posts(:published)
    get :show, { :id => post_.id }
    assert_response :success
    assert_template 'show'
  end

  ##
  # Actions related to edit.
  ##

  def test_should_edit_an_item
    get :edit, { :id => posts(:published) }
    assert_response :success
    assert_template 'edit'
  end

  ##
  # Actions related to update.
  ##

  def test_should_update_an_item

    post_ = posts(:published)
    post :update, { :id => post_.id, :title => 'Updated' }
    assert_response :redirect
    assert_redirected_to :controller => 'admin/posts', :action => 'edit', :id => post_.id

  end

  def test_should_update_an_item_and_redirect_to_index

    options = Typus::Configuration.options.merge(:index_after_save => true)
    Typus::Configuration.stubs(:options).returns(options)

    post :update, { :id => posts(:published), :title => 'Updated' }
    assert_response :redirect
    assert_redirected_to :action => 'index'

  end

end