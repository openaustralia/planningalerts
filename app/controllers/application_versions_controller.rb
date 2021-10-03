# typed: true
# frozen_string_literal: true

class ApplicationVersionsController < ApplicationController
  extend T::Sig

  sig { void }
  def index
    @application = T.let(Application.find(params[:application_id]), T.nilable(Application))
  end
end
