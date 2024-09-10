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
    @params.all? { |p| request.params.key?(p.to_s) }
  end
end

Rails.application.routes.draw do
  namespace :admin do
    # Feature flag admin
    constraints CanAccessFlipperUI do
      mount Flipper::UI.app(Flipper) => "flipper", as: :flipper
    end

    resources :users, except: [:new, :create] do
      collection do
        get :export_confirmed_emails
      end
    end
    resources :alerts, only: [:index, :show] do
      member do
        post :unsubscribe
      end
    end
    resources :comments, except: [:destroy, :new, :create] do
      member do
        post :resend
        post :confirm
      end
    end
    resources :reports, only: [:index, :show, :destroy]
    resources :authorities, except: :destroy do
      member do
        post :import
      end
    end
    resources :applications, only: [:index, :show, :destroy]
    resources :api_keys, except: [:destroy, :new, :create]
    resources :api_usages, only: :index
    resources :background_jobs, only: :index
    resources :test_emails, only: [:index, :create]
    resources :roles, only: [:index, :show]

    root to: "users#index"
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

  scope "/profile" do
    resources :alerts, except: :show
    resources :api_keys, only: [:create, :index] do
      collection do
        get :confirm
      end
    end
    get "comments", to: "comments#personal", as: "personal_comments"
  end
  get "/profile", to: redirect("/profile/alerts")

  resources :alerts, only: [], param: :confirm_id do
    member do
      get :unsubscribe
    end
  end
  get "/alerts/signup", to: redirect("/profile/alerts/new")

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
      get :external
    end
    collection do
      get :address
      get :search
      get :trending
    end
    resources :comments, only: [:create, :update] do
      member do
        # This little hack allows us to put the "clear" button inside the form rather than having a seperate form
        # just for that button
        patch '' => 'comments#destroy', constraints: QueryParamsPresentConstraint.new(:clear)
        post :publish
      end
    end
    resources :versions, only: [:index], controller: "application_versions"
  end
  get "/applications/:id/nearby", to: redirect("/applications/%{id}")

  resources :comments, only: [:index] do
    member do
      # "preview" route only currently used in tailwind theme
      get :preview
    end
    resources :reports, only: %i[new create] do
      collection do
        get :thank_you
      end
    end
  end

  resources :authorities, only: %i[index show] do
    get :under_the_hood
    member do
      get :boundary
    end

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
  end

  resources :contact_messages, only: :create do
    collection do
      get :thank_you    
    end
  end

  resources :geocode_queries, only: [:index, :show]

  get "/atdis/test", to: redirect("/get_involved")
  get "/atdis/specification", to: redirect("https://github.com/openaustralia/atdis/raw/master/docs/ATDIS-1.0.2%20Application%20Tracking%20Data%20Interchange%20Specification%20(v1.0.2).pdf")

  namespace :api_keys do
    resource :non_commercial, only: [:new, :create]
    resources :requests, only: [:new]
    resources :paid, only: [:new, :create]
  end

  get "api/howto" => "documentation#api_howto"
  get "api/developer" => "documentation#api_developer"
  get "about" => "documentation#about"
  get "faq" => "documentation#faq"
  get "getinvolved", to: redirect("/get_involved")
  get "get_involved" => "documentation#get_involved"
  get "how_to_write_a_scraper" => "documentation#how_to_write_a_scraper"
  get "how_to_lobby_your_local_council" => "documentation#how_to_lobby_your_local_council"
  # TODO: I'm guessing we'll want to rename other help related urls above to something a bit more like this one?
  namespace :documentation, path: "/help" do
    get :contact
  end

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
end
