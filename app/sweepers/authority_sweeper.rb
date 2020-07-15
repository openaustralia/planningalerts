# typed: strict
# frozen_string_literal: true

require "standalone_sweeper"

class AuthoritySweeper < StandaloneSweeper
  extend T::Sig

  observe Authority

  sig { params(_authority: Authority).void }
  def after_create(_authority)
    expire_page(controller: "static", action: %w[about faq get_involved])
    expire_page(controller: "api", action: "howto")
    expire_page(controller: "authorities", action: "index")
  end

  sig { params(_authority: Authority).void }
  def after_update(_authority)
    expire_page(controller: "authorities", action: "index")
  end

  sig { params(_authority: Authority).void }
  def after_destroy(_authority)
    expire_page(controller: "static", action: %w[about faq get_involved])
    expire_page(controller: "api", action: "howto")
    expire_page(controller: "authorities", action: "index")
  end
end
