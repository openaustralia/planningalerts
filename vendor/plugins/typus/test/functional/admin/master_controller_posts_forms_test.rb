require 'test/helper'

# Here we test everything related to forms.

class Admin::PostsControllerTest < ActionController::TestCase

  # Our model definition is:
  #
  #   Post:
  #     fields:
  #       form: title, body, created_at, status, published_at
  #
  def test_form_when_new

    get :new
    assert_template :new

    # Page includes a form.
    assert_select "form"

    # Page includes 4 elements.
    assert_select "form input", 2
    assert_select "form textarea", 1
    assert_select "form select", 6

    # title
    assert_select 'label[for="post_title"]'
    assert_select 'input#post_title[type="text"]'

    # body
    assert_select 'label[for="post_body"]'
    assert_select 'textarea#post_body'

    # status
    assert_select 'label[for="post_status"]'
    assert_select 'select#post_status'

  end

end