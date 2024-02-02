# typed: strict
# frozen_string_literal: true

class ThemesController < ApplicationController
  extend T::Sig

  sig { void }
  def toggle
    return unless Flipper.enabled?(:switch_themes, current_user)

    update_tailwind_theme(!show_tailwind_theme?)
    notice = if show_tailwind_theme?
               "Thank you for being an early tester of the new design. Please remember to report any problems that you encounter."
             else
               "We're sad to see you go. Please let us know why you switched back"
             end
    redirect_to root_path, notice:
  end
end
