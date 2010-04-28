require 'standalone_sweeper'

class AlertSweeper < StandaloneSweeper
  observe Alert

  def after_create(alert)
    expire_page(:controller => 'alerts', :action => 'statistics')
  end

  def after_destroy(alert)
    expire_page(:controller => 'alerts', :action => 'statistics')
  end
end