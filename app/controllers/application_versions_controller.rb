# typed: true
# frozen_string_literal: true

class ApplicationVersionsController < ApplicationController
  def index
    @application = Application.find(params[:application_id])
  end
end
