# typed: strict
# frozen_string_literal: true

module Admin
  class BackgroundJobsController < Admin::ApplicationController
    extend T::Sig

    sig { void }
    def index; end
  end
end
