# typed: strict
# frozen_string_literal: true

class ProfilesController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!

  sig { void }
  def show; end

  sig { void }
  def comments
    comments = T.must(current_user).comments.visible.order(confirmed_at: :desc).page(params[:page])
    @comments = T.let(comments, T.nilable(ActiveRecord::Relation))
  end
end
