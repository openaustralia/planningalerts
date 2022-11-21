# typed: strict
# frozen_string_literal: true

class MyBaseDeviseController < ApplicationController
  extend T::Sig

  layout :devise_layout

  private

  sig { returns(String) }
  def devise_layout
    # For one particular devise action (editing a user profile) we don't want to use the "minimal" layout
    if controller_name == "registrations" && action_name == "edit"
      "standard"
    else
      "minimal"
    end
  end
end
