# typed: strict
# frozen_string_literal: true

module Admin
  class AnnouncementsController < Admin::ApplicationController
    extend T::Sig

    # A new announcement starts now unless staff change it. Administrate's own `new` builds an empty one.
    sig { void }
    def new
      resource = new_resource(starts_at: Time.current)
      authorize_resource(resource)
      render locals: { page: Administrate::Page::Form.new(dashboard, resource) }
    end
  end
end
