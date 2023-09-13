# typed: strict
# frozen_string_literal: true

class ThemesController < ApplicationController
  extend T::Sig

  sig { void }
  def toggle
    cookies.signed[:planningalerts_theme] = if show_tailwind_theme?
                                              nil
                                            else
                                              "tailwind"
                                            end
    redirect_back(fallback_location: root_path)
  end
end
