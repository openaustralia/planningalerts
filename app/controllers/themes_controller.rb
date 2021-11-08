# typed: strict
# frozen_string_literal: true

class ThemesController < ApplicationController
  extend T::Sig

  sig { void }
  def toggle
    session[:theme] = session[:theme] == "bootstrap" ? "standard" : "bootstrap"
    redirect_to root_url
  end
end
