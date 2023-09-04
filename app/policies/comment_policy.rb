# typed: strict
# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(User) }
  attr_reader :user

  sig { returns(Comment) }
  attr_reader :comment

  sig { params(user: User, comment: Comment).void }
  def initialize(user, comment)
    super
    @user = user
    @comment = comment
  end

  sig { returns(T::Boolean) }
  def preview?
    comment.user_id == user.id
  end
end
