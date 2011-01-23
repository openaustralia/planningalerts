require 'test/helper'

class RoutesTest < ActiveSupport::TestCase

  include ActionController::TestCase::Assertions

  def test_should_verify_admin_named_routes

    routes = ActionController::Routing::Routes.named_routes.routes.keys

    expected = [ :admin_sign_up, :admin_sign_in, :admin_sign_out, 
                 :admin_recover_password, :admin_reset_password, 
                 :admin_dashboard, 
                 :admin_quick_edit ]

    expected.each { |route| assert routes.include?(route) }

  end

  def test_should_verify_admin_named_routes_for_typus_users

    routes = ActionController::Routing::Routes.named_routes.routes.keys

    expected = [ :admin_typus_users, 
                 :admin_typus_user ]

    expected.each { |route| assert !routes.include?(route) }

    expected = [ :relate_admin_typus_user,
                 :unrelate_admin_typus_user ]

    expected.each { |route| assert !routes.include?(route) }

  end

  def test_should_verify_default_admin_named_routes_for_posts

    routes = ActionController::Routing::Routes.named_routes.routes.keys

    expected = [ :admin_posts, 
                 :admin_post ]

    expected.each { |route| assert !routes.include?(route) }

  end

  def test_should_verify_custom_admin_named_routes_for_posts

    routes = ActionController::Routing::Routes.named_routes.routes.keys

    expected = [ :cleanup_admin_posts, 
                 :send_as_newsletter_admin_post, 
                 :preview_admin_post ]

    expected.each { |route| assert !routes.include?(route) }

  end

  def test_should_verify_generated_routes_for_typus_controller

    assert_routing '/admin', :controller => 'typus', :action => 'dashboard'

    actions = [ 'sign_up', 'sign_in', 'sign_out', 
                'recover_password', 'reset_password', 
                'quick_edit' ]

    actions.each { |a| assert_routing "/admin/#{a}", :controller => 'typus', :action => a }

  end

end