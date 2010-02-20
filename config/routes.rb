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
  map.connect 'unsubscribe.php', :controller => 'signup', :action => 'old_unsubscribe'
  
  map.signup '', :controller => "signup"
  map.root :signup
  map.connect 'preview', :controller => 'signup', :action => 'preview'
  map.check_mail 'checkmail', :controller => 'signup', :action => 'check_mail'
  map.confirmed 'confirmed', :controller => 'signup', :action => 'confirmed'
  map.unsubscribe 'unsubscribe', :controller => 'signup', :action => 'unsubscribe'

  map.api_howto 'api/howto', :controller => 'api', :action => 'howto'
  map.api 'api', :controller => 'api', :action => 'index'
  
  map.about 'about', :controller => 'static', :action => 'about'
  map.faq 'faq', :controller => 'static', :action => 'faq'
  map.get_involved 'getinvolved', :controller => 'static', :action => 'get_involved'

  map.resources 'applications', :only => :index
  map.resources 'authorities', :only => [] do |authority|
    authority.resources :applications, :only => :index
  end

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'  
end
