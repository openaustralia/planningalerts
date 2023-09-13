# typed: strict
# frozen_string_literal: true

class ThemesController < ApplicationController
  extend T::Sig

  sig { void }
  def toggle
    return unless Flipper.enabled?(:switch_themes, current_user)

    update_tailwind_theme(!show_tailwind_theme?)
    redirect_back(fallback_location: root_path)
  end
end
