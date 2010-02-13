class StandaloneSweeper < ActionController::Caching::Sweeper
  include ActionController::UrlWriter

  protected
  
  # Providing my own implementation of expire_page because we don't have a controller set when this sweeper is
  # used from a rake task
  def expire_page(options)
    url = url_for options.merge(:only_path => true, :skip_relative_url_root => true)
    ActionController::Base.expire_page(url)
  end
end

