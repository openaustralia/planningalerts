require 'test/helper'

class Admin::PostsControllerTest < ActionController::TestCase

  def setup
    @typus_user = typus_users(:admin)
    @request.session[:typus_user_id] = @typus_user.id
  end

end