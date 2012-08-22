PlanningalertsApp::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, ActiveAdmin::Devise.config

  # Redirect old urls
  match 'apihowto.php' => redirect('/api/howto')
  match 'about.php' => redirect('/about')
  match 'faq.php' => redirect('/faq')
  match 'getinvolved.php' => redirect('/getinvolved')
  # Can't do the redirects in the routing as above because the redirect depends
  # on the passed parameters
  match 'api.php' => 'api#old_index'
  match 'api' => 'api#old_index'
  
  resources :alerts, :only => [:new, :create], :path_names => {:new => 'signup'} do
    collection do
      get :statistics
      get :widget_prototype
    end
    member do
      get :area
	    post :area
      get :unsubscribe
    end
  end

  resources :applications, :only => [:index, :show] do
    member do
      get :nearby
    end
    collection do
      get :search
    end
    resources :comments, :only => [:create, :show]
  end
  
  resources :comments, :only => [:index] do
    resources :reports, :only => [:new, :create]
  end

  resources :authorities, :only => [:index] do
    resources :applications, :only => [:index]
  end

  match 'api/howto' => 'api#howto', :as => :api_howto
  match 'api' => 'api#index', :as => :api

  match 'about' => 'static#about', :as => :about
  match 'faq' => 'static#faq', :as => :faq
  match 'getinvolved' => 'static#get_involved', :as => :get_involved

  match '/' => 'applications#address', :as => :address_applications
  
  match 'layar/getpoi' => 'layar#getpoi'

  match 'comments/:id/confirmed' => 'comments#confirmed', :as => :confirmed_comment
  match 'alerts/:id/confirmed' => 'email_confirmable/confirm#confirmed', :as => :confirmed_alert, :resource => 'alerts'

  match '/vanity(/:action(/:id(.:format)))', :controller=>:vanity

  root :to => 'applications#address'

  unless Rails.application.config.consider_all_requests_local
    match '*not_found', :to => 'static#error_404'
  end
end
