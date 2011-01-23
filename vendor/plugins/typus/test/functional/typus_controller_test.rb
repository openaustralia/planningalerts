require 'test/helper'

class TypusControllerTest < ActionController::TestCase

  ##
  # get :sign_in
  ##

  def test_should_sign_in
    get :sign_in
    assert_response :success
    assert_template 'sign_in'
  end

  def test_should_sign_in_with_post_and_redirect_to_dashboard
    typus_user = typus_users(:admin)
    post :sign_in, { :typus_user => { :email => typus_user.email, :password => '12345678' } }
    assert_equal typus_user.id, @request.session[:typus_user_id]
    assert_response :redirect
    assert_redirected_to admin_dashboard_path
  end

  def test_should_sign_in_with_post_and_redirect_to_sign_in_with_an_error
    post :sign_in, { :typus_user => { :email => 'john@example.com', :password => 'XXXXXXXX' } }
    assert_response :redirect
    assert_redirected_to admin_sign_in_path
    assert_equal "The email and/or password you entered is invalid.", flash[:error]
  end

  def test_should_not_sign_in_a_disabled_user
    typus_user = typus_users(:disabled_user)
    post :sign_in, { :typus_user => { :email => typus_user.email, :password => '12345678' } }
    assert_nil @request.session[:typus_user_id]
    assert_response :redirect
    assert_redirected_to admin_sign_in_path
  end

  def test_should_not_sign_in_a_removed_role
    typus_user = typus_users(:removed_role)
    post :sign_in, { :typus_user => { :email => typus_user.email, :password => '12345678' } }
    assert_equal typus_user.id, @request.session[:typus_user_id]
    assert_response :redirect
    assert_redirected_to admin_dashboard_path
    get :dashboard
    assert_redirected_to admin_sign_in_path
    assert_nil @request.session[:typus_user_id]
    assert_equal "Role does no longer exists.", flash[:notice]
  end

  def test_should_not_send_recovery_password_link_to_unexisting_user

    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    Typus::Configuration.stubs(:options).returns(options)

    post :recover_password, { :typus_user => { :email => 'unexisting' } }
    assert_response :redirect
    assert_redirected_to admin_recover_password_path
    [ :notice, :error, :warning ].each { |f| assert !flash[f] }

  end

  def test_should_send_recovery_password_link_to_existing_user

    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    Typus::Configuration.stubs(:options).returns(options)

    admin = typus_users(:admin)
    post :recover_password, { :typus_user => { :email => admin.email } }

    assert_response :redirect
    assert_redirected_to admin_sign_in_path
    assert_equal "Password recovery link sent to your email.", flash[:success]

  end

  def test_should_sign_out
    admin = typus_users(:admin)
    @request.session[:typus_user_id] = admin.id
    get :sign_out
    assert_nil @request.session[:typus_user_id]
    assert_response :redirect
    assert_redirected_to admin_sign_in_path
    [ :notice, :error, :warning ].each { |f| assert !flash[f] }
  end

  def test_should_verify_block_users_on_the_fly

    admin = typus_users(:admin)
    @request.session[:typus_user_id] = admin.id
    get :dashboard
    assert_response :success

    # Disable user ...

    admin.status = false
    admin.save

    get :dashboard
    assert_response :redirect
    assert_redirected_to admin_sign_in_path

    assert_equal "Typus user has been disabled.", flash[:notice]
    assert_nil @request.session[:typus_user_id]

  end

  ##
  # reset_password
  ##

  def test_should_not_reset_password

    get :reset_password
    assert_response :redirect
    assert_redirected_to admin_sign_in_path

  end

  def test_should_reset_password_when_recover_password_is_true

    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    Typus::Configuration.stubs(:options).returns(options)

    typus_user = typus_users(:admin)
    get :reset_password, { :token => typus_user.token }

    assert_response :success
    assert_template 'reset_password'

  end

  def test_should_redirect_to_sign_in_user_after_reset_password

    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    Typus::Configuration.stubs(:options).returns(options)

    typus_user = typus_users(:admin)
    post :reset_password, { :token => typus_user.token, :typus_user => { :password => '12345678', :password_confirmation => '12345678' } }

    assert_response :redirect
    assert_redirected_to admin_dashboard_path

  end

  def test_should_be_redirected_if_password_does_not_match_confirmation

    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    Typus::Configuration.stubs(:options).returns(options)

    typus_user = typus_users(:admin)
    post :reset_password, { :token => typus_user.token, :typus_user => { :password => 'drowssap', :password_confirmation => 'drowssap2' } }
    assert_response :success

  end

  def test_should_only_be_allowed_to_reset_password

    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    Typus::Configuration.stubs(:options).returns(options)

    typus_user = typus_users(:admin)
    post :reset_password, { :token => typus_user.token, :typus_user => { :password => 'drowssap', :password_confirmation => 'drowssap', :role => 'superadmin' } }
    typus_user.reload
    assert_not_equal typus_user.role, 'superadmin'

  end

  def test_should_return_404_on_reset_passsword_if_token_is_not_valid

    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    Typus::Configuration.stubs(:options).returns(options)

    assert_raise(ActiveRecord::RecordNotFound) { get :reset_password, { :token => 'INVALID' } }

  end

  def test_should_reset_password_with_valid_token


    options = Typus::Configuration.options.merge(:email => true)
    Typus::Configuration.stubs(:options).returns(options)

    typus_user = typus_users(:admin)
    get :reset_password, { :token => typus_user.token }
    assert_response :success
    assert_template 'reset_password'

  end

  ##
  # sign_up
  ##

  def test_should_verify_sign_up_works

    TypusUser.destroy_all
    assert TypusUser.find(:all).empty?

    get :sign_up

    assert_response :success
    assert_template 'sign_up'
    assert_match /layouts\/typus/, @controller.active_layout.to_s
    assert_equal "Enter your email below to create the first user.", flash[:notice]

  end

  def test_should_should_not_sign_up_invalid_email

    TypusUser.destroy_all

    post :sign_up, :typus_user => { :email => 'example.com' }

    assert_response :success
    assert_equal "That doesn't seem like a valid email address.", flash[:error]

  end

  def test_should_sign_up_valid_email

    TypusUser.destroy_all

    assert_difference 'TypusUser.count' do
      post :sign_up, :typus_user => { :email => 'john@example.com' }
    end

    assert_response :redirect
    assert_redirected_to admin_dashboard_path
    assert_equal %Q[Password set to "columbia".], flash[:notice]
    assert @request.session[:typus_user_id]

  end

  ##
  # sign_in
  ##

  def test_should_render_sign_in

    options = Typus::Configuration.options.merge(:app_name => 'Typus Test')
    Typus::Configuration.stubs(:options).returns(options)

    get :sign_in
    assert_response :success

    assert_select 'title', "Typus Test - Sign in"
    assert_select 'h1', 'Typus Test'
    assert_match /layouts\/typus/, @controller.active_layout.to_s

  end

  def test_should_redirect_to_sign_up_when_no_typus_users
    TypusUser.destroy_all
    get :sign_in
    assert_response :redirect
    assert_redirected_to admin_sign_up_path
  end

  def test_should_verify_typus_sign_in_layout_does_not_include_recover_password_link
    get :sign_in
    assert !@response.body.include?('Recover password')
  end

  def test_should_verify_typus_sign_in_layout_includes_recover_password_link
    options = Typus::Configuration.options.merge(:email => 'john@example.com')
    Typus::Configuration.stubs(:options).returns(options)
    get :sign_in
    assert @response.body.include?('Recover password')
  end

  ##
  # sign_out
  ##

  def test_should_verify_sign_out
    @request.session[:typus_user_id] = typus_users(:admin).id
    get :sign_out
    assert_nil @request.session[:typus_user_id]
    assert_redirected_to admin_sign_in_path
  end

  ##
  # get dashboard
  ##

  def test_should_redirect_to_sign_in_when_not_signed_in
    @request.session[:typus_user_id] = nil
    get :dashboard
    assert_response :redirect
    assert_redirected_to admin_sign_in_path
  end

  # FIXME
  def test_should_render_dashboard

    return

    @request.session[:typus_user_id] = typus_users(:admin).id
    get :dashboard

    assert_response :success
    assert_template 'dashboard'
    assert_match /layouts\/admin/, @controller.active_layout.to_s
    assert_select 'title', "#{Typus::Configuration.options[:app_name]} - Dashboard"

    [ 'Typus', 
      %Q[href="/admin/sign_out"], 
      %Q[href="/admin/typus_users/edit/#{@request.session[:typus_user_id]}] ].each do |string|
      assert_match string, @response.body
    end

    %w( typus_users posts pages assets ).each { |r| assert_match "/admin/#{r}/new", @response.body }
    %w( statuses orders ).each { |r| assert_no_match /\/admin\/#{r}\n/, @response.body }

    assert_select 'body div#header' do
      assert_select 'a', 'Admin Example'
      assert_select 'a', 'Sign out'
    end

    partials = %w( _sidebar.html.erb )
    partials.each { |p| assert_match p, @response.body }

  end

  def test_should_show_add_links_in_resources_list_for_editor
    @request.session[:typus_user_id] = typus_users(:editor).id
    get :dashboard
    assert_match '/admin/posts/new', @response.body
    assert_no_match /\/admin\/typus_users\/new/, @response.body
    assert_no_match /\/admin\/categories\/new/, @response.body
  end

  def test_should_show_add_links_in_resources_list_for_designer
    @request.session[:typus_user_id] = typus_users(:designer).id
    get :dashboard
    assert_no_match /\/admin\/posts\/new/, @response.body
    assert_no_match /\/admin\/typus_users\/new/, @response.body
  end

end