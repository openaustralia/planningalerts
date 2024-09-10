# typed: strict
# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  extend T::Sig

  sig { returns(User) }
  attr_reader :user

  sig { returns(Comment) }
  def comment
    T.cast(@comment, Comment)
  end

  sig { params(user: User, comment: T.any(Comment, T.class_of(Comment))).void }
  def initialize(user, comment)
    super
    @user = user
    @comment = comment
  end

  sig { returns(T::Boolean) }
  def index?
    true
  end

  sig { returns(T::Boolean) }
  def show?
    comment.published?
  end

  sig { returns(T::Boolean) }
  def preview?
    # Can only preview your own comments
    comment.user_id == user.id
  end

  sig { returns(T::Boolean) }
  def update?
    # Can only edit your own comments that have not yet been published
    comment.user_id == user.id && !comment.published
  end

  sig { returns(T::Boolean) }
  def destroy?
    # Can only destroy your own comments that have not yet been published
    comment.user_id == user.id && !comment.published
  end

  sig { returns(T::Boolean) }
  def publish?
    # Can only publish your own comments that have not yet been published
    comment.user_id == user.id && !comment.published
  end

  class Scope < ApplicationPolicy::Scope
    # TODO: Is this for public or your own comments?
    sig { returns(ActiveRecord::Relation) }
    def resolve
      scope.published
    end
  end
end
