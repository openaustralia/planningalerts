class FormatConstraint
  def matches?(request)
    request.format.html?
  end
end

# Given query parameters, constraint passes
# if all the parameters are present
class QueryParamsPresentConstraint
  def initialize(*params)
    @params = params
  end

  def matches?(request)
    @params.all?{|p| request.query_parameters[p.to_s].present?}
  end
end

PlanningalertsApp::Application.routes.draw do
  constraints :subdomain => "api" do
    constraints FormatConstraint.new do
      match "(*path)" => redirect{|p,r| "http://www.#{r.domain(2)}/#{p[:path]}"}
    end
  end

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

  # Route API separately
  scope :format => true do
    get 'authorities/:authority_id/applications' => 'api#authority', as: nil
    get 'applications' => 'api#postcode', as: nil,
      constraints: QueryParamsPresentConstraint.new(:postcode)
    get 'applications' => 'api#suburb', as: nil,
      constraints: QueryParamsPresentConstraint.new(:suburb)
    get 'applications' => 'api#point', as: nil,
      constraints: QueryParamsPresentConstraint.new(:address)
    get 'applications' => 'api#point', as: nil,
      constraints: QueryParamsPresentConstraint.new(:lat, :lng)
    get 'applications' => 'api#area', as: nil,
      constraints: QueryParamsPresentConstraint.new(:bottom_left_lat, :bottom_left_lng,
        :top_right_lat, :top_right_lng)
    get 'applications' => 'api#all', as: nil
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

  resources :authorities, :only => [:index, :show] do
    resources :applications, :only => [:index] do
      collection do
        get :per_day
        get :per_week
      end
    end
    collection do
      get :test_feed
    end
  end

  namespace :atdis do
    get :test
    post :test, :action => 'test_redirect'
    get 'feed/:number/atdis/1.0/applications.json', :action => 'feed', :as => :feed
    get :specification
    get :guidance
  end

  match 'api/howto' => 'api#howto', :as => :api_howto
  match 'api' => 'api#index', :as => :api

  match 'about' => 'static#about', :as => :about
  match 'faq' => 'static#faq', :as => :faq
  match 'getinvolved' => 'static#get_involved', :as => :get_involved
  match 'how_to_write_a_scraper' => 'static#how_to_write_a_scraper'
  match 'how_to_lobby_your_local_council' => 'static#how_to_lobby_your_local_council'

  match 'donate' => 'static#donate'
  match 'donate/thanks' => 'static#donate_thanks'
  match 'donate/cancel' => 'static#donate_cancel'

  match '/' => 'applications#address', :as => :address_applications

  match 'layar/getpoi' => 'layar#getpoi'

  match 'comments/:id/confirmed' => 'comments#confirmed', :as => :confirmed_comment
  match 'alerts/:id/confirmed' => 'email_confirmable/confirm#confirmed', :as => :confirmed_alert, :resource => 'alerts'

  match '/vanity(/:action(/:id(.:format)))', :controller=>:vanity

  root :to => 'applications#address'

  match '/404', :to => 'static#error_404'
  match "/500", :to => 'static#error_500'
end
