# typed: strict
# frozen_string_literal: true

module ApiKeys
  class NonCommercialsController < ApplicationController
    extend T::Sig

    sig { void }
    def new
      unless Flipper.enabled?(:request_api_keys, current_user)
        raise ActiveRecord::RecordNotFound
      end
    end
  end
end
