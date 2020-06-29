# typed: true
# frozen_string_literal: true

class ThemesController < ApplicationController
  def toggle
    session[:theme] = session[:theme] == "bootstrap" ? "standard" : "bootstrap"
    redirect_to root_url
  end
end
