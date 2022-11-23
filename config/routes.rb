# typed: false
# frozen_string_literal: true

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

Rails.application.routes.draw do
  namespace :admin do
    # Feature flag admin
    constraints CanAccessFlipperUI do
      mount Flipper::UI.app(Flipper) => "flipper", as: :flipper
    end

    resources :applications, only: [:index, :show, :destroy]
    resources :authorities, except: :destroy do
      member do
        post :import
      end
    end
    resources :users, except: [:new, :create]
    resources :reports, only: [:index, :show, :destroy]
    resources :comments, except: [:destroy, :new, :create] do
      member do
        post :resend
        post :confirm
      end
    end
    resources :api_keys, except: [:destroy, :new, :create]
    resources :alerts, only: [:index, :show] do
      member do
        post :unsubscribe
      end

      collection do
        get :export_active_emails
      end
    end
    resources :background_jobs, only: :index
    resources :api_usages, only: :index
    # Doing this weird thing where we add both the singular and the plural
    # of the resources because administrate only seems to recognise the route
    # when it's plural while we want the singular resource for the update action
    resources :site_settings, only: :index
    resource :site_settings, only: :update

    root to: "applications#index"
  end

  constraints subdomain: "api" do
    constraints FormatConstraint.new do
      get "(*path)" => redirect { |p, r| "http://www.#{r.domain(2)}/#{p[:path]}" }
    end
  end

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/admin/jobs'
  end

  devise_for :users

  resource :profile, only: [:show] do
    resources :api_keys, only: :create
    resources :alerts, only: %i[index edit update destroy create], controller: :alerts_new
    get :comments
  end

  resources :alerts, only: %i[new create update edit], path_names: { new: "signup", edit: "area" }, param: :confirm_id do
    member do
      get :confirmed
      get :unsubscribe
    end
  end

  # Route API separately
  scope format: true do
    get "authorities/:authority_id/applications" => "api#authority", as: nil
    get "applications" => "api#suburb_postcode", as: nil,
        constraints: QueryParamsPresentConstraint.new(:postcode)
    get "applications" => "api#suburb_postcode", as: nil,
        constraints: QueryParamsPresentConstraint.new(:suburb)
    get "applications" => "api#point", as: nil,
        constraints: QueryParamsPresentConstraint.new(:address)
    get "applications" => "api#point", as: nil,
        constraints: QueryParamsPresentConstraint.new(:lat, :lng)
    get "applications" => "api#area", as: nil,
        constraints: QueryParamsPresentConstraint.new(
          :bottom_left_lat, :bottom_left_lng,
          :top_right_lat, :top_right_lng
        )
    get "applications" => "api#date_scraped", as: nil,
        constraints: QueryParamsPresentConstraint.new(:date_scraped)
    get "applications" => "api#all", as: nil
  end

  resources :applications, only: %i[index show] do
    member do
      get :nearby
    end
    collection do
      get :search
      get :trending
    end
    resources :comments, only: [:create]
    resources :versions, only: [:index], controller: "application_versions"
  end

  resources :comments, only: [:index] do
    member do
      get :confirmed
    end
    resources :reports, only: %i[new create]
  end

  resources :authorities, only: %i[index show] do
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
    get :under_the_hood
  end

  namespace :atdis do
    get :test
    post :test, action: "test_redirect"
    get "feed/:number/atdis/1.0/applications.json", action: "feed", as: :feed
    get :specification
  end

  get "api/howto" => "api#howto", as: :api_howto

  get "about" => "static#about", as: :about
  get "faq" => "static#faq", as: :faq
  get "getinvolved" => "static#get_involved", as: :get_involved
  get "how_to_write_a_scraper" => "static#how_to_write_a_scraper"
  get "how_to_lobby_your_local_council" => "static#how_to_lobby_your_local_council"

  get "/" => "applications#address", as: :address_applications

  ## Use the donations form on OAF for now.
  get "donations/new", to: redirect("https://www.oaf.org.au/donate/planningalerts/")
  get "donations/create", to: redirect("https://www.oaf.org.au/donate/planningalerts/")
  get "donations", to: redirect("https://www.oaf.org.au/donate/planningalerts/")
  get "donate", to: redirect("https://www.oaf.org.au/donate/planningalerts/"), as: nil

  root to: "applications#address"

  get "/404", to: "static#error_404"
  get "/500", to: "static#error_500"

  post "/cuttlefish/event", to: "cuttlefish#event"

  # TODO: Only needed while we're testing the tailwind theme
  resource :theme, only: [] do
    post 'toggle'
  end
end
