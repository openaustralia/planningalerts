# typed: false
# frozen_string_literal: true

# Workaround for ActionController::Caching::Sweeper not getting defined early enough
require "rails/observers/action_controller/caching/sweeper"

class StandaloneSweeper < ActionController::Caching::Sweeper
  extend T::Sig

  # GeneratedUrlHelpers is provided by sorbet-rails as a drop-in replacement for
  # Rails.application.routes.url_helpers
  # include GeneratedUrlHelpers
  include Rails.application.routes.url_helpers

  protected

  # Providing my own implementation of expire_page because we don't have a controller set when this sweeper is
  # used from a rake task
  sig { params(options: T::Hash[T.untyped, T.untyped]).void }
  def expire_page(options)
    if options[:action].is_a?(Array)
      options[:action].each do |action|
        ActionController::Base.expire_page(url_for(options.merge(only_path: true, action: action)))
      end
    else
      ActionController::Base.expire_page(url_for(options.merge(only_path: true)))
    end
  end
end
