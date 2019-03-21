# frozen_string_literal: true

require "will_paginate/array"

class ApplicationsController < ApplicationController
  # TODO: Switch actions from JS to JSON format and remove this
  skip_before_action :verify_authenticity_token, only: %i[per_day per_week]
  before_action :check_application_redirect, only: %i[show nearby]

  def index
    @description = +"Recent applications"

    if params[:authority_id]
      # TODO: Handle the situation where the authority name isn't found
      @authority = Authority.find_short_name_encoded!(params[:authority_id])
      apps = @authority.applications
      @description << " from #{@authority.full_name_and_state}"
    else
      @description << " within the last #{Application.nearby_and_recent_max_age_months} months"
      apps = Application.where("application_versions.date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)
    end

    @applications = apps
                    .paginate(page: params[:page], per_page: 30)
    @alert = Alert.new
  end

  def trending
    @applications = Application
                    .where("application_versions.date_scraped > ?", 4.weeks.ago)
                    .reorder(visible_comments_count: :desc)
                    .limit(20)
  end

  # JSON api for returning the number of scraped applications per day
  def per_day
    authority = Authority.find_short_name_encoded!(params[:authority_id])
    respond_to do |format|
      format.js do
        render json: authority.applications_per_day
      end
    end
  end

  def per_week
    authority = Authority.find_short_name_encoded!(params[:authority_id])
    respond_to do |format|
      format.js do
        render json: authority.applications_per_week
      end
    end
  end

  def address
    @q = params[:q]
    @radius = (params[:radius] || 2000).to_f
    @sort = params[:sort] || "time"
    per_page = 30
    @page = params[:page]
    if @q
      result = GoogleGeocodeService.call(@q)
      if result.error
        @other_addresses = []
        @error = result.error
      else
        @q = result.top.full_address
        @alert = Alert.new(address: @q)
        @other_addresses = result.rest.map(&:full_address)
        @applications = Application.near(
          [result.top.lat, result.top.lng], @radius / 1000,
          units: :km,
          latitude: "application_versions.lat",
          longitude: "application_versions.lng"
        )
        @applications = @applications.reorder("distance") if @sort == "distance"
        @applications = @applications
                        .paginate(page: params[:page], per_page: per_page)
        @rss = applications_path(format: "rss", address: @q, radius: @radius)
      end
    end
    @trending = Application
                .where("application_versions.date_scraped > ?", 4.weeks.ago)
                .reorder(visible_comments_count: :desc)
                .limit(4)
    @set_focus_control = "q"
    # Use a different template if there are results to display
    render "address_results" if @q && @error.nil?
  end

  def search
    # TODO: Fix this hacky ugliness
    per_page = request.format == Mime[:html] ? 30 : Application.per_page

    @q = params[:q]
    if @q
      @applications = Application.search(@q, fields: [:description], order: { date_scraped: :desc }, highlight: { tag: "<span class=\"highlight\">" }, page: params[:page], per_page: per_page)
      @rss = search_applications_path(format: "rss", q: @q, page: nil)
    end
    @description = @q ? "Search: #{@q}" : "Search"

    respond_to do |format|
      format.html
      format.rss { render "api/index", format: :rss, layout: false, content_type: Mime[:xml] }
    end
  end

  def show
    @application = Application.find(params[:id])
    @comments = @application.comments.visible.order(:confirmed_at).includes(:replies)
    @nearby_count = @application.find_all_nearest_or_recent.size
    @add_comment = AddComment.new(
      application: @application
    )
    # Required for new email alert signup form
    @alert = Alert.new(address: @application.address)

    @councillors = @application.councillors_available_for_contact

    respond_to do |format|
      format.html
    end
  end

  def nearby
    @sort = params[:sort]
    @rss = nearby_application_url(params.permit(%i[id sort page]).merge(format: "rss", page: nil))

    # TODO: Fix this hacky ugliness
    per_page = request.format == Mime[:html] ? 30 : Application.per_page

    @application = Application.find(params[:id])
    case @sort
    when "time"
      @applications = @application.find_all_nearest_or_recent
    when "distance"
      @applications = Application.unscoped do
        @application.find_all_nearest_or_recent
      end
    else
      redirect_to sort: "time"
      return
    end
    @applications = @applications
                    .paginate page: params[:page], per_page: per_page

    respond_to do |format|
      format.html { render "nearby" }
      format.rss { render "api/index", format: :rss, layout: false, content_type: Mime[:xml] }
    end
  end

  private

  def check_application_redirect
    redirect = ApplicationRedirect.find_by(application_id: params[:id])
    redirect_to(id: redirect.redirect_application_id) if redirect
  end
end
