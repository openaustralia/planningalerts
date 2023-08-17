# typed: strict
# frozen_string_literal: true

class MyBaseDeviseController < ApplicationController
  extend T::Sig

  layout :devise_layout

  private

  sig { returns(String) }
  def devise_layout
    # For one particular devise action (editing a user profile) we don't want to use the "minimal" layout
    # Also we don't want the minimal layout ever with the tailwind theme
    if show_tailwind_theme? || (controller_name == "registrations" && action_name == "edit")
      "application"
    else
      "minimal"
    end
  end

  # This method is duplicated from application_controller.rb. Really we should be extracting it into
  # something like a concern (or a module) but had trouble making things work with sorbet. So, for the
  # time being just duplicated code. I know.
  # TODO: Remove duplication with application_controller.rb
  sig { returns(T::Boolean) }
  def show_tailwind_theme?
    # We're intentionally not checking whether the feature flag is enabled here because we want
    # the new theme to be shown even if you're logged out. The feature flag just enables the button
    # that allows you to do the switching. Cookies are signed so the value can be manipulated by
    # users outside of pushing the button
    cookies.signed[:planningalerts_theme] == "tailwind"
  end
end
