require 'test/helper'

class TypusTest < ActiveSupport::TestCase

  def test_should_verify_models
    models = [ Category, Comment, Post, TypusUser ]
    models.each { |m| assert m.superclass.equal?(ActiveRecord::Base) }
  end

  def test_should_verify_fixtures_are_loaded
    assert_equal 3, Category.count
    assert_equal 4, Comment.count
    assert_equal 4, Post.count
    assert_equal 5, TypusUser.count
  end

end