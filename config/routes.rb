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
    @params.all? { |p| request.params[p.to_s].present? }
  end
end

PlanningalertsApp::Application.routes.draw do
  constraints subdomain: "api" do
    constraints FormatConstraint.new do
      get "(*path)" => redirect{|p,r| "http://www.#{r.domain(2)}/#{p[:path]}"}
    end
  end

  ActiveAdmin.routes(self)

  patch "admin/councillor_contribution/:id/mark_as_reviewed", to: "councillor_contributions#mark_as_reviewed", as: :mark_as_reviewed

  devise_for :users

  # Redirect old urls
  get 'apihowto.php' => redirect('/api/howto')
  get 'about.php' => redirect('/about')
  get 'faq.php' => redirect('/faq')
  get 'getinvolved.php' => redirect('/getinvolved')
  # Can't do the redirects in the routing as above because the redirect depends
  # on the passed parameters
  get 'api.php' => 'api#old_index'
  get 'api' => 'api#old_index', as: :api_old_index

  resources :alerts, only: [:new, :create], path_names: {new: 'signup'} do
    collection do
      get :statistics
      get :widget_prototype
    end
    member do
      get :confirmed
      get :area
	    post :area
      get :unsubscribe
    end
  end

  # Route API separately
  scope format: true do
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
    get 'applications' => 'api#date_scraped', as: nil,
      constraints: QueryParamsPresentConstraint.new(:date_scraped)
    get 'applications' => 'api#all', as: nil
  end

  resources :applications, only: [:index, :show] do
    member do
      get :nearby
    end
    collection do
      get :search
    end
    resources :comments, only: [:show]
    resources :add_comments, only: [:create]
  end

  resources :comments, only: [:index] do
    member do
      get :confirmed
    end
    collection do
      post :writeit_reply_webhook
    end
    resources :reports, only: [:new, :create]
  end

  resources :authorities, only: [:index, :show] do
    resources :applications, only: [:index] do
      collection do
        get :per_day
        get :per_week
      end
    end
    resources :comments, only: [:index] do
      collection do
        get :per_week
      end
    end
    resources :councillor_contributions, only:[:new, :show]
    collection do
      get :test_feed
    end
  end

  post "/authorities/:authority_id/councillor_contributions/new", to: "councillor_contributions#new"
  patch "/auhtorities/:authority_id/councillor_contributions/add_contributor", to: "councillor_contributions#add_contributor", as: :add_contributor_authority_councillor_contribution
  post "/authorities/:authority_id/councillor_contributions/source", to: "councillor_contributions#source", as: :add_source_authority_councillor_contribution
  patch "/authorities/:authority_id/councillor_contributions/thank_you", to: "councillor_contributions#thank_you", as: :authority_councillor_contribution_thank_you

  namespace :atdis do
    get :test
    post :test, action: 'test_redirect'
    get 'feed/:number/atdis/1.0/applications.json', action: 'feed', as: :feed
    get :specification
    get :guidance
  end

  get 'api/howto' => 'api#howto', as: :api_howto
  get 'api' => 'api#index', as: :api

  get 'about' => 'static#about', as: :about
  get 'faq' => 'static#faq', as: :faq
  get 'getinvolved' => 'static#get_involved', as: :get_involved
  get 'how_to_write_a_scraper' => 'static#how_to_write_a_scraper'
  get 'how_to_lobby_your_local_council' => 'static#how_to_lobby_your_local_council'

  get 'donate' => 'static#donate'
  get 'donate/thanks' => 'static#donate_thanks'
  get 'donate/cancel' => 'static#donate_cancel'

  get '/' => 'applications#address', as: :address_applications

  get 'layar/getpoi' => 'layar#getpoi'

  get '/vanity(/:action(/:id(.:format)))', controller: :vanity

  resources :donations, only: [:new, :create]

  get 'donations' => redirect('/donations/new')

  resources :performance, only: [:index] do
    collection do
      get :alerts
      get :comments
    end
  end

  root to: 'applications#address'

  get '/404', to: 'static#error_404'
  get "/500", to: 'static#error_500'
end
