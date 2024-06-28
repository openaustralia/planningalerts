# typed: strict
# frozen_string_literal: true

class ProfilesController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!

  layout "profile"

  # TODO: Move redirect to routes
  sig { void }
  def show
    redirect_to profile_alerts_url
  end

  sig { void }
  def comments
    # We also want to include comments that have been hidden
    comments = T.must(current_user).comments.published.order(published_at: :desc).page(params[:page])
    @comments = T.let(comments, T.nilable(ActiveRecord::Relation))
  end
end
