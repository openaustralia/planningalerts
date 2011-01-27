PlanningalertsApp::Application.routes.draw do
  # Redirect old urls
  # TODO: Once we have moved to Rails 3 we can do redirection directly inside here
  match 'apihowto.php' => 'api#old_howto'
  match 'about.php' => 'static#old_about'
  match 'faq.php' => 'static#old_faq'
  match 'getinvolved.php' => 'static#old_get_involved'
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

  resources :authorities, :only => [] do
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

  match 'comments/:id/confirmed' => 'email_confirmable/confirm#confirmed', :as => :confirmed_comment, :resource => 'comments'
  match 'alerts/:id/confirmed' => 'email_confirmable/confirm#confirmed', :as => :confirmed_alert, :resource => 'alerts'

  root :to => 'applications#address'
end
