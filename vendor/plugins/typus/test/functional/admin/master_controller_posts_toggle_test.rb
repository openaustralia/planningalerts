require 'test/helper'

class Admin::PostsControllerTest < ActionController::TestCase

  def test_should_toggle_an_item

    @request.env['HTTP_REFERER'] = '/admin/posts'

    post = posts(:unpublished)
    get :toggle, { :id => post.id, :field => 'status' }

    assert_response :redirect
    assert_redirected_to @request.env['HTTP_REFERER']
    assert_equal "Post status changed.", flash[:success]
    assert Post.find(post.id).status

  end

end