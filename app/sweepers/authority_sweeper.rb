require 'standalone_sweeper'

class AuthoritySweeper < StandaloneSweeper
  observe Authority

  def after_create(authority)
    expire_page(controller: 'alerts', action: 'statistics')
    expire_page(controller: 'static', action: %w( about faq get_involved ))
    expire_page(controller: 'api', action: 'howto')
    expire_page(controller: 'authorities', action: 'index')
  end

  def after_update(authority)
    expire_page(controller: 'authorities', action: 'index')
  end

  def after_destroy(authority)
    expire_page(controller: 'alerts', action: 'statistics')
    expire_page(controller: 'static', action: %w( about faq get_involved ))
    expire_page(controller: 'api', action: 'howto')
    expire_page(controller: 'authorities', action: 'index')
  end
end