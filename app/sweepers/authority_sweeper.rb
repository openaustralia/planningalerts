require 'standalone_sweeper'

class AuthoritySweeper < StandaloneSweeper
  observe Authority

  def after_create(authority)
    expire_page(:controller => 'alerts', :action => %w( new checkmail ))
    expire_page(:controller => 'static', :action => %w( about faq get_involved ))
    expire_page(:controller => 'api', :action => 'howto')
  end

  def after_destroy(authority)
    expire_page(:controller => 'alerts', :action => %w( new checkmail ))
    expire_page(:controller => 'static', :action => %w( about faq get_involved ))
    expire_page(:controller => 'api', :action => 'howto')
  end
end