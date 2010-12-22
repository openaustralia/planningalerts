ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # Redirect old urls
  # TODO: Once we have moved to Rails 3 we can do redirection directly inside here
  map.connect 'apihowto.php', :controller => 'api', :action => 'old_howto'
  map.connect 'about.php', :controller => 'static', :action => 'old_about'
  map.connect 'faq.php', :controller => 'static', :action => 'old_faq'
  map.connect 'getinvolved.php', :controller => 'static', :action => 'old_get_involved'
  map.connect 'api.php', :controller => 'api', :action => 'old_index'
  map.connect 'api', :controller => 'api', :action => 'old_index'
  map.connect 'confirmed.php', :controller => 'alerts', :action => 'old_confirmed'
  map.connect 'confirmed', :controller => 'alerts', :action => 'old_confirmed'
  map.connect 'unsubscribe.php', :controller => 'alerts', :action => 'old_unsubscribe'
  map.connect 'unsubscribe', :controller => 'alerts', :action => 'old_unsubscribe'
  
  map.new_alert '/alerts/signup', :controller => "alerts", :action => "signup"
  map.checkmail_alerts 'alerts/checkmail', :controller => 'alerts', :action => 'check_mail'
  map.confirmed_alert 'alerts/:cid/confirmed', :controller => 'alerts', :action => 'confirmed'
  map.unsubscribe 'alerts/:cid/unsubscribe', :controller => 'alerts', :action => 'unsubscribe'
  map.alert_area 'alerts/:cid/area', :controller => 'alerts', :action => 'area'
  map.statistics_alerts 'alerts/statistics', :controller => 'alerts', :action => 'statistics'

  map.api_howto 'api/howto', :controller => 'api', :action => 'howto'
  map.api 'api', :controller => 'api', :action => 'index'
  
  map.about 'about', :controller => 'static', :action => 'about'
  map.faq 'faq', :controller => 'static', :action => 'faq'
  map.get_involved 'getinvolved', :controller => 'static', :action => 'get_involved'

  map.address_applications '', :controller => 'applications', :action => 'address'

  map.resources 'applications', :only => [:index, :show], :collection => {:search => :get}, :member => {:nearby => :get}
  map.resources 'authorities', :only => [] do |authority|
    authority.resources :applications, :only => :index
  end
  
  map.connect 'layar/:action', :controller => 'layar'
  map.root :address_applications

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'  
end
