# typed: strict
# frozen_string_literal: true

class ThemesController < ApplicationController
  extend T::Sig

  sig { void }
  def toggle
    session[:theme] = session[:theme] == "tailwind" ? "standard" : "tailwind"
    redirect_to root_url
  end
end
