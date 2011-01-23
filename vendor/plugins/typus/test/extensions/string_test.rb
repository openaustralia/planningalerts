require 'test/helper'

class StringTest < ActiveSupport::TestCase

  def test_extract_controller

    assert_equal ['posts'], 'admin/posts'.extract_controller
    assert_equal ['typus_users'], 'admin/typus_users'.extract_controller
    assert_equal ['delayed', 'jobs'], 'admin/delayed/jobs'.extract_controller

    assert_equal ['posts'], 'typus/posts'.extract_controller('typus')
    assert_equal ['typus_users'], 'typus/typus_users'.extract_controller('typus')
    assert_equal ['delayed', 'tasks'], 'typus/delayed/tasks'.extract_controller('typus')

  end

  def test_extract_resource
    assert_equal 'posts', 'admin/posts'.extract_resource
    assert_equal 'typus_users', 'admin/typus_users'.extract_resource
    assert_equal 'delayed/tasks', 'admin/delayed/tasks'.extract_resource
  end

  def test_extract_class
    assert_equal Post, 'admin/posts'.extract_class
    assert_equal TypusUser, 'admin/typus_users'.extract_class
    assert_equal Delayed::Task, 'admin/delayed/tasks'.extract_class
  end

  def test_extract_human_name
    assert_equal 'Post', 'admin/posts'.extract_human_name
    assert_equal 'Typus user', 'admin/typus_users'.extract_human_name
    assert_equal 'Delayed task', 'admin/delayed/tasks'.extract_human_name
  end

  def test_should_return_post_actions_on_index
    assert_equal %w( cleanup ), 'Post'.typus_actions_on('index')
    assert_equal %w( cleanup ), 'Post'.typus_actions_on(:index)
  end

  def test_should_return_post_actions_on_edit
    assert_equal %w( send_as_newsletter preview ), 'Post'.typus_actions_on('edit')
    assert_equal %w( send_as_newsletter preview ), 'Post'.typus_actions_on(:edit)
  end

  def test_should_verify_typus_actions_on_unexisting_returns_is_empty
    assert 'TypusUser'.typus_actions_on('unexisting').empty?
    assert 'TypusUser'.typus_actions_on(:unexisting).empty?
  end

  def test_should_verify_typus_actions_on_index_returns_an_array
    assert 'Post'.typus_actions_on('index').kind_of?(Array)
    assert 'Post'.typus_actions_on(:index).kind_of?(Array)
  end

end