# typed: strict
# frozen_string_literal: true

class ProfilesController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!
  after_action :verify_authorized, except: %i[show comments]
  # after_action :verify_policy_scoped, only: :comments

  layout "profile"

  sig { void }
  def show
    redirect_to profile_alerts_url if show_tailwind_theme?
  end

  # The actions "comments" and "comment_preview" really belong on a new controller called something like "MyComments"
  sig { void }
  def comments
    # TODO: We want the user to be able to see their hidden comments too
    comments = T.must(current_user).comments.visible.order(confirmed_at: :desc).page(params[:page])
    @comments = T.let(comments, T.nilable(ActiveRecord::Relation))
  end

  sig { void }
  def comment_preview
    comment = Comment.find(params[:id])
    @comment = T.let(comment, T.nilable(Comment))
    authorize @comment, :preview?
  end
end
