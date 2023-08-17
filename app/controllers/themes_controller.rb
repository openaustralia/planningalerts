# typed: strict
# frozen_string_literal: true

class ThemesController < ApplicationController
  extend T::Sig

  sig { void }
  def toggle
    cookies.signed[:planningalerts_theme] = ("tailwind" if cookies.signed[:planningalerts_theme] != "tailwind")
    redirect_back(fallback_location: root_path)
  end
end
