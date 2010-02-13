require 'standalone_sweeper'

class AuthoritySweeper < StandaloneSweeper
  observe Authority

  def after_create(authority)
    expire_page(:controller => 'signup', :action => 'index')
  end

  def after_destroy(authority)
    expire_page(:controller => 'signup', :action => 'index')
  end
end