require 'standalone_sweeper'

class StatSweeper < StandaloneSweeper
  observe Stat

  def after_save(stat)
    expire_page(:controller => 'signup', :action => 'index')
  end
end