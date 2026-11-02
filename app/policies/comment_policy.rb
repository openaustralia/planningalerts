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
  def create?
    may_comment? && comments_open?
  end

  sig { returns(T::Boolean) }
  def update?
    own_unpublished? && may_comment? && comments_open?
  end

  # Not affected by disabled commenting: deleting a draft that can't be sent does no harm
  sig { returns(T::Boolean) }
  def destroy?
    own_unpublished?
  end

  sig { returns(T::Boolean) }
  def publish?
    own_unpublished? && may_comment? && comments_open?
  end

  class Scope < ApplicationPolicy::Scope
    # TODO: #2163 Is this for public or your own comments?
    sig { returns(ActiveRecord::Relation) }
    def resolve
      scope.published
    end
  end

  private

  sig { returns(T::Boolean) }
  def own_unpublished?
    comment.user_id == user.id && !comment.published
  end

  sig { returns(T::Boolean) }
  def may_comment?
    !user.comments_disabled?
  end

  sig { returns(T::Boolean) }
  def comments_open?
    !comment.application&.comments_disabled?
  end
end
