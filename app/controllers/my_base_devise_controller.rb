# typed: strict
# frozen_string_literal: true

class MyBaseDeviseController < ApplicationController
  extend T::Sig

  layout :devise_layout

  private

  # TODO: Can we just comment this out?
  sig { returns(String) }
  def devise_layout
    # For one particular devise action (editing a user profile) we don't want to use the "minimal" layout
    # Also we don't want the minimal layout ever with the tailwind theme
    "application"
  end
end
