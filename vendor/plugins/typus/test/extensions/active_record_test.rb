require 'test/helper'

class ActiveRecordTest < ActiveSupport::TestCase

  def setup
    @typus_user = typus_users(:admin)
  end

  def test_should_verify_to_dom

    assert_equal "typus_user_new", TypusUser.new.to_dom

    assert_equal "typus_user_#{@typus_user.id}", @typus_user.to_dom
    assert_equal "prefix_typus_user_#{@typus_user.id}", @typus_user.to_dom(:prefix => 'prefix')
    assert_equal "typus_user_#{@typus_user.id}_suffix", @typus_user.to_dom(:suffix => 'suffix')
    assert_equal "prefix_typus_user_#{@typus_user.id}_suffix", @typus_user.to_dom(:prefix => 'prefix', :suffix => 'suffix')

  end

  def test_should_verify_to_label
    assert @typus_user.respond_to?(:to_label)
  end

  def test_should_verify_to_label_when_model_has_typus_name
    @typus_user.stubs(:typus_name).returns('typus_name')
    assert_equal 'typus_name', @typus_user.to_label
  end

  def test_should_verify_to_label_when_model_has_name
    @typus_user.stubs(:name).returns('name')
    assert_equal 'name', @typus_user.to_label
  end

end
