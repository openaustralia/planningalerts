# typed: false
# frozen_string_literal: true

require "standalone_sweeper"

class ApplicationSweeper < StandaloneSweeper
  extend T::Sig

  observe Application

  sig { params(_application: Application).void }
  def after_create(_application)
    expire_page(controller: "authorities", action: "index")
  end

  sig { params(_application: Application).void }
  def after_destroy(_application)
    expire_page(controller: "authorities", action: "index")
  end
end
