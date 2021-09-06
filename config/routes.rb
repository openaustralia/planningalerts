# typed: true
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
  constraints subdomain: "api" do
    constraints FormatConstraint.new do
      get "(*path)" => redirect { |p, r| "http://www.#{r.domain(2)}/#{p[:path]}" }
    end
  end

  ActiveAdmin.routes(self)
  namespace "admin" do
    resource :site_settings, only: :update
  end

  require 'sidekiq/web'
  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/admin/jobs'
  end


  devise_for :users

  resources :alerts, only: %i[new create], path_names: { new: "signup" } do
    member do
      get :confirmed
      get :area
      post :area
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
      get :geocoding
    end
    resources :comments, only: [:show]
    # TODO: Why is add_comments a separate controller?
    resources :add_comments, only: [:create]
    resources :versions, only: [:index], controller: "application_versions"
  end

  resources :comments, only: [:index] do
    member do
      get :confirmed
    end
    collection do
      post :writeit_reply_webhook
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
    resources :councillor_contributions, only: %i[new show]
    get :under_the_hood
  end

  resources :councillor_contributions, only: [:index]

  resources :geocode_queries, only: [:index, :show]

  post "/authorities/:authority_id/councillor_contributions/new", to: "councillor_contributions#new"
  patch "/authorities/:authority_id/councillor_contributions/add_contributor", to: "councillor_contributions#add_contributor", as: :add_contributor_authority_councillor_contribution
  post "/authorities/:authority_id/councillor_contributions/source", to: "councillor_contributions#source", as: :add_source_authority_councillor_contribution
  patch "/authorities/:authority_id/councillor_contributions/thank_you", to: "councillor_contributions#thank_you", as: :authority_councillor_contribution_thank_you

  namespace :atdis do
    get :test
    post :test, action: "test_redirect"
    get "feed/:number/atdis/1.0/applications.json", action: "feed", as: :feed
    get :specification
  end

  namespace :api_keys do
    resource :request_non_commercial, only: [:new, :create]
  end

  get "api/howto" => "api#howto", as: :api_howto
  get "api" => "api#index", as: :api

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
  get "donate", to: redirect("https://www.oaf.org.au/donate/planningalerts/")

  root to: "applications#address"

  get "/404", to: "static#error_404"
  get "/500", to: "static#error_500"

  post "/cuttlefish/event", to: "cuttlefish#event"

  # TODO: Only needed while we're testing the bootstrap theme
  resource :theme, only: [] do
    post 'toggle'
  end
end
