PlanningalertsApp::Application.routes.draw do
  devise_for :users

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
    end
    member do
      get :area
	    post :area
      get :unsubscribe
      get :confirmed, :resource => 'alerts'
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
    collection do
      get :broken
    end
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

  root :to => 'applications#address'
end
