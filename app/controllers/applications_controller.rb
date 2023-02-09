# typed: strict
# frozen_string_literal: true

class ApplicationsController < ApplicationController
  extend T::Sig

  before_action :check_application_redirect, only: %i[show nearby]

  sig { void }
  def index
    authority_id = T.cast(params[:authority_id], T.nilable(String))

    description = +"Recent applications within the last #{Application.nearby_and_recent_max_age_months} months"

    if authority_id
      # TODO: Handle the situation where the authority name isn't found
      authority = Authority.find_short_name_encoded!(authority_id)
      description << " from #{authority.full_name_and_state}"
      apps = authority.applications
    else
      apps = Application
    end
    apps = apps.includes(:current_version).order("first_date_scraped DESC").where("first_date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)

    @authority = T.let(authority, T.nilable(Authority))
    @description = T.let(description, T.nilable(String))
    @applications = T.let(apps.page(params[:page]).per(30), T.untyped)
    @alert = T.let(Alert.new(user: User.new), T.nilable(Alert))
  end

  sig { void }
  def trending
    @applications = Application.trending.limit(20)
  end

  sig { void }
  def per_week
    params_authority_id = T.cast(params[:authority_id], String)

    authority = Authority.find_short_name_encoded!(params_authority_id)
    respond_to do |format|
      format.json do
        render json: authority.new_applications_per_week
      end
    end
  end

  sig { void }
  def address
    params_q = T.cast(params[:q], T.nilable(String))
    params_radius = T.cast(params[:radius], T.nilable(T.any(String, Numeric)))
    params_sort = T.cast(params[:sort], T.nilable(String))
    params_page = T.cast(params[:page], T.nilable(String))
    params_time = T.cast(params[:time], T.nilable(String))

    @q = T.let(params_q, T.nilable(String))
    radius = params_radius ? params_radius.to_f : 2000.0
    # We don't want to allow a search radius that's too large
    radius = [2000.0, radius].min
    @radius = T.let(radius, T.nilable(Float))

    time = params_time ? params_time.to_i : 365
    @time = T.let(time, T.nilable(Integer))

    sort = params_sort || "time"
    @sort = T.let(sort, T.nilable(String))
    per_page = 30
    @page = T.let(params_page, T.nilable(String))
    result = GoogleGeocodeService.call(T.must(@q))
    top = result.top
    if top.nil?
      @full_address = @q
      @other_addresses = T.let([], T.nilable(T::Array[String]))
      @error = T.let(result.error, T.nilable(String))
      @trending = T.let(Application.trending.limit(4), T.untyped)
      render "home/index"
    else
      @full_address = T.let(top.full_address, T.nilable(String))
      @alert = Alert.new(address: @q, user: User.new)
      @other_addresses = T.must(result.rest).map(&:full_address)
      @applications = Application.with_current_version.near(
        [top.lat, top.lng], radius / 1000,
        units: :km,
        latitude: "application_versions.lat",
        longitude: "application_versions.lng"
      )
      @applications = @applications.where("date_scraped > ?", time.days.ago) if Flipper.enabled?(:extra_options_on_address_search, current_user)
      if sort == "time"
        @applications = @applications
                        .reorder("application_versions.date_scraped DESC")
      end
      @applications = @applications.page(params[:page]).per(per_page)
    end
  end

  sig { void }
  def search
    params_q = T.cast(params[:q], T.nilable(String))

    # TODO: Fix this hacky ugliness
    per_page = request.format == Mime[:html] ? 30 : Application.max_per_page

    @q = params_q
    @applications = Application.search(@q, fields: [:description], order: { first_date_scraped: :desc }, highlight: { tag: "<span class=\"highlight\">" }, page: params[:page], per_page:) if @q
    @description = @q ? "Search: #{@q}" : "Search"
  end

  sig { void }
  def show
    application = Application.find(params[:id])
    @application = T.let(application, T.nilable(Application))
    @comments = T.let(application.comments.confirmed.order(:confirmed_at), T.untyped)
    comment = Comment.new(
      application:,
      user: User.new,
      # If the user is logged in by default populate the name on the comment with their name
      name: current_user&.name
    )
    @comment = T.let(comment, T.nilable(Comment))
    # Required for new email alert signup form
    @alert = Alert.new(address: application.address, user: User.new)

    respond_to do |format|
      format.html
    end
  end

  sig { void }
  def nearby
    params_sort = T.cast(params[:sort], T.nilable(String))

    @sort = params_sort
    if @sort != "time" && @sort != "distance"
      redirect_to sort: "time"
      return
    end

    # TODO: Fix this hacky ugliness
    per_page = request.format == Mime[:html] ? 30 : Application.max_per_page

    @application = Application.find(params[:id])
    @applications = @application.find_all_nearest_or_recent.page(params[:page]).per(per_page)
    @applications = @applications.reorder("first_date_scraped DESC") if @sort == "time"
  end

  private

  sig { void }
  def check_application_redirect
    redirect = ApplicationRedirect.find_by(application_id: params[:id])
    redirect_to(id: redirect.redirect_application_id) if redirect
  end
end
