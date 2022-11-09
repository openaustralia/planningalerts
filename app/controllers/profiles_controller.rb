# typed: strict
# frozen_string_literal: true

class ProfilesController < ApplicationController
  extend T::Sig

  before_action :authenticate_user!

  sig { void }
  def show; end
end
