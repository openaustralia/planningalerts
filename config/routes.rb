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
    resources :users, except: [:new, :create] do
      collection do
        get :export_confirmed_emails
      end
    end
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

    end
    resources :background_jobs, only: :index
    resources :api_usages, only: :index

    root to: "applications#index"
  end

  constraints subdomain: "api" do
    constraints FormatConstraint.new do
      get "(*path)" => redirect { |p, r| "http://www.#{r.domain(2)}/#{p[:path]}" }
    end
  end

  require 'sidekiq/web'
  require "sidekiq/cron/web"
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/admin/jobs'
  end

  devise_for :users, controllers: {
    confirmations: "users/confirmations",
    registrations: "users/registrations"
  }
  
  devise_scope :user do
    # After people fill in the form to register it redirects to this page
    # which asks people to go to their email and confirm their email address
    # TODO: I shouldn't need to prefix the route with users here. Why is this happening? What have I done wrong?
    get "users/sign_up/check_email",  to: "users/registrations#check_email", as: "check_email_user_registration"
  end

  namespace :users do
    resource :activation, only: [:new, :create, :edit, :update] do
      get :check_email
    end
  end

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
    resources :reports, only: %i[new create] do
      collection do
        get :thank_you
      end
    end
  end

  resources :authorities, only: %i[index show] do
    resources :applications, only: [:index] do
      collection do
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

  resources :geocode_queries, only: [:index, :show]

  namespace :atdis do
    get :test
    post :test, action: "test_redirect"
    get "feed/:number/atdis/1.0/applications.json", action: "feed", as: :feed
    get :specification
  end

  get "api/howto" => "documentation#api_howto"
  get "about" => "documentation#about"
  get "faq" => "documentation#faq"
  get "getinvolved", to: redirect("/get_involved")
  get "get_involved" => "documentation#get_involved"
  get "how_to_write_a_scraper" => "documentation#how_to_write_a_scraper"
  get "how_to_lobby_your_local_council" => "documentation#how_to_lobby_your_local_council"

  get "/" => "applications#address", as: :address_applications, constraints: QueryParamsPresentConstraint.new(:q)
  get "/" => "home#index"

  ## Use the donations form on OAF for now.
  get "donations/new", to: redirect("https://www.oaf.org.au/donate/planningalerts/")
  get "donations/create", to: redirect("https://www.oaf.org.au/donate/planningalerts/")
  get "donations", to: redirect("https://www.oaf.org.au/donate/planningalerts/")
  get "donate", to: redirect("https://www.oaf.org.au/donate/planningalerts/"), as: nil

  root to: "applications#address"

  get "/404", to: "documentation#error_404"
  get "/500", to: "documentation#error_500"

  post "/cuttlefish/event", to: "cuttlefish#event"

  # TODO: Only needed while we're testing the tailwind theme
  resource :theme, only: [] do
    post 'toggle'
  end
end
