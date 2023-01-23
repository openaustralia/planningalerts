# typed: strict
# frozen_string_literal: true

class HomeController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    @trending = T.let(Application.trending.limit(4), T.untyped)
  end
end
