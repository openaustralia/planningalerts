# typed: strict
# frozen_string_literal: true

module Admin
  class HomesController < Admin::ApplicationController
    extend T::Sig

    sig { void }
    def index; end
  end
end
