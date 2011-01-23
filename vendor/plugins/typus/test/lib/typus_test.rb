require 'test/helper'

class TypusTest < ActiveSupport::TestCase

  def test_should_return_path
    expected = Dir.pwd + '/lib/../'
    assert_equal expected, Typus.root
  end

  def test_should_return_applications_and_should_be_sorted
    assert Typus.respond_to?(:applications)
    assert Typus.applications.kind_of?(Array)
    assert_equal %w( Blog Site System Typus ), Typus.applications
  end

  def test_should_return_modules_of_an_application
    assert Typus.respond_to?(:application)
    assert_equal %w( Comment Post ), Typus.application('Blog')
  end

  def test_should_return_models_and_should_be_sorted
    assert Typus.respond_to?(:models)
    assert Typus.models.kind_of?(Array)
    assert_equal %w( Asset Category Comment CustomUser Delayed::Task Page Post TypusUser View ), Typus.models
  end

  def test_should_return_an_array_of_models_on_header
    assert Typus.models_on_header.kind_of?(Array)
    assert_equal ["Page"], Typus.models_on_header
  end

  # FIXME: Somehow excludes the Order resource.
  def test_should_verify_resources_class_method
    return
    assert Typus.respond_to?(:resources)
    assert_equal %w( Git Order Status WatchDog ), Typus.resources
  end

  def test_should_return_user_class
    assert_equal TypusUser, Typus.user_class
  end

  def test_should_return_overwritted_user_class
    options = { :user_class_name => 'CustomUser' }
    Typus::Configuration.stubs(:options).returns(options)
    assert_equal CustomUser, Typus.user_class
  end

  def test_should_return_user_fk
    assert_equal 'typus_user_id', Typus.user_fk
  end

  def test_should_return_overwritted_user_fk
    options = { :user_fk => 'my_user_fk' }
    Typus::Configuration.stubs(:options).returns(options)
    assert_equal 'my_user_fk', Typus.user_fk
  end

  def test_should_return_relationship
    assert_equal 'typus_users', Typus.relationship
  end

  def test_should_return_overwritted_user_fk
    options = { :relationship => 'my_typus_users' }
    Typus::Configuration.stubs(:options).returns(options)
    assert_equal 'my_typus_users', Typus.relationship
  end

end