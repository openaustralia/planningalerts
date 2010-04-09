require 'standalone_sweeper'

class StatSweeper < StandaloneSweeper
  observe Stat

  def after_save(stat)
    expire_page(:controller => 'alerts', :action => %w( index check_mail ))
    expire_page(:controller => 'static', :action => %w( about faq get_involved ))
    expire_page(:controller => 'api', :action => 'howto')
  end
end