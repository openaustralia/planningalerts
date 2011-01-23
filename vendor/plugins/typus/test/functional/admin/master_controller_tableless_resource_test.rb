require 'test/helper'

class Admin::StatusControllerTest < ActionController::TestCase

  def setup
    @request.session[:typus_user_id] = typus_users(:admin).id
  end

  def test_should_verify_admin_can_go_to_index
    get :index
    assert_response :success
    assert_template 'index'
  end

  def test_should_verify_status_is_not_available_if_user_not_logged
    @request.session[:typus_user_id] = nil
    get :index
    assert_response :redirect
    assert_redirected_to admin_sign_in_path(:back_to => '/admin/status')
  end

  def test_should_verify_admin_cannot_go_to_show
    get :show
    assert_response :redirect
    assert_redirected_to admin_dashboard_path
    assert_equal "Admin can't go to show on status.", flash[:notice]
  end

  def test_should_verify_editor_can_not_go_to_index
    @request.session[:typus_user_id] = typus_users(:editor).id
    get :index
    assert_response :redirect
    assert_equal "Editor can't go to index on status.", flash[:notice]
  end

end