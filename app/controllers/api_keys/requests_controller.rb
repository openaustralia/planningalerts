# typed: strict
# frozen_string_literal: true

module ApiKeys
  class RequestsController < ApplicationController
    extend T::Sig

    # TODO: Need to be logged in to use this page

    sig { void }
    def new
      unless Flipper.enabled?(:request_api_keys, current_user)
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
