require 'standalone_sweeper'

class ApplicationSweeper < StandaloneSweeper
  observe Application

  def after_create(application)
    expire_page(:controller => 'alerts', :action => 'statistics')
  end

  def after_destroy(application)
    expire_page(:controller => 'alerts', :action => 'statistics')
  end
end