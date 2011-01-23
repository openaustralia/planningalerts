require 'test/helper'

class Admin::AssetsControllerTest < ActionController::TestCase

  def setup
    @request.session[:typus_user_id] = typus_users(:admin).id
  end

  def test_should_test_polymorphic_relationship_message

    post_ = posts(:published)
    get :new, { :back_to => "/admin/posts/#{post_.id}/edit", 
                :resource => post_.class.name, :resource_id => post_.id }

    assert_select 'body div#flash' do
      assert_select 'p', "You're adding a new Asset to Post. Do you want to cancel it?"
      assert_select 'a', "Do you want to cancel it?"
    end

  end

  def test_should_create_a_polymorphic_relationship

    post_ = posts(:published)

    assert_difference('post_.assets.count') do
      post :create, { :back_to => "/admin/posts/edit/#{post_.id}", 
                      :resource => post_.class.name, :resource_id => post_.id }
    end

    assert_response :redirect
    assert_redirected_to '/admin/posts/edit/1#assets'
    assert_equal "Asset successfully assigned to Post.", flash[:success]

  end

  def test_should_render_edit_and_verify_message_on_polymorphic_relationship

    post_ = posts(:published)
    get :edit, { :id => assets(:first).id, 
                 :back_to => "/admin/posts/#{post_.id}/edit", 
                 :resource => post_.class.name, :resource_id => post_.id }

    assert_select 'body div#flash' do
      assert_select 'p', "You're updating a Asset for Post. Do you want to cancel it?"
      assert_select 'a', "Do you want to cancel it?"
    end

  end

  def test_should_return_to_back_to_url

    options = Typus::Configuration.options.merge(:index_after_save => true)
    Typus::Configuration.stubs(:options).returns(options)

    post_ = posts(:published)
    asset_ = assets(:first)

    post :update, { :back_to => "/admin/posts/#{post_.id}/edit", :resource => post_.class.name, :resource_id => post_.id, :id => asset_.id }
    assert_response :redirect
    assert_redirected_to '/admin/posts/1/edit#assets'
    assert_equal "Asset successfully updated.", flash[:success]

  end

end