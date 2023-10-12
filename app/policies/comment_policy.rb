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
    # Can only preview your own comments
    # TODO: Remove temporary powers for admins to view all previews
    comment.user_id == user.id || user.admin?
  end

  sig { returns(T::Boolean) }
  def update?
    # Can only edit your own comments that have not yet been published
    comment.user_id == user.id && !comment.previewed
  end

  sig { returns(T::Boolean) }
  def destroy?
    # Can only desroy your own comments that have not yet been published
    comment.user_id == user.id && !comment.previewed
  end
end
