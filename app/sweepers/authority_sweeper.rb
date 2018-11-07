require "standalone_sweeper"

class AuthoritySweeper < StandaloneSweeper
  observe Authority

  def after_create(_authority)
    expire_page(controller: "alerts", action: "statistics")
    expire_page(controller: "static", action: %w[about faq get_involved])
    expire_page(controller: "api", action: "howto")
    expire_page(controller: "authorities", action: "index")
  end

  def after_update(_authority)
    expire_page(controller: "authorities", action: "index")
  end

  def after_destroy(_authority)
    expire_page(controller: "alerts", action: "statistics")
    expire_page(controller: "static", action: %w[about faq get_involved])
    expire_page(controller: "api", action: "howto")
    expire_page(controller: "authorities", action: "index")
  end
end
