require 'will_paginate/array'

class ApplicationsController < ApplicationController
  # TODO: Switch actions from JS to JSON format and remove this
  skip_before_action :verify_authenticity_token, only: [:per_day, :per_week]

  def index
    @description = "Recent applications"

    if params[:authority_id]
      # TODO Handle the situation where the authority name isn't found
      @authority = Authority.find_by_short_name_encoded!(params[:authority_id])
      apps = @authority.applications
      @description << " from #{@authority.full_name_and_state}"
    else
      @description << " within the last #{Application.nearby_and_recent_max_age_months} months"
      apps = Application.where("date_scraped > ?", Application.nearby_and_recent_max_age_months.months.ago)
    end

    @applications = apps.paginate(page: params[:page], per_page: 30)
  end

  # JSON api for returning the number of scraped applications per day
  def per_day
    authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    respond_to do |format|
      format.js do
        render json: authority.applications_per_day
      end
    end
  end

  def per_week
    authority = Authority.find_by_short_name_encoded!(params[:authority_id])
    respond_to do |format|
      format.js do
        render json: authority.applications_per_week
      end
    end
  end

  def address
    @q = params[:q]
    @radius = params[:radius] || 2000
    @sort = params[:sort] || 'time'
    per_page = 30
    @page = params[:page]
    if @q
      location = Location.geocode(@q)
      if location.error
        @other_addresses = []
        @error = "Address #{location.error}"
      else
        @q = location.full_address
        @alert = Alert.new(address: @q)
        @other_addresses = location.all[1..-1].map{|l| l.full_address}
        @applications = case @sort
                        when 'distance'
                          Application.near([location.lat, location.lng], @radius.to_f / 1000, units: :km).reorder('distance').paginate(page: params[:page], per_page: per_page)
                        else # date_scraped
                          Application.near([location.lat, location.lng], @radius.to_f / 1000, units: :km).paginate(page: params[:page], per_page: per_page)
                        end
        @rss = applications_path(format: 'rss', address: @q, radius: @radius)
      end
    end
    @set_focus_control = "q"
    # Use a different template if there are results to display
    if @q && @error.nil?
      render "address_results"
    end
  end

  def search
    # TODO: Fix this hacky ugliness
    if request.format == Mime::HTML
      per_page = 30
    else
      per_page = Application.per_page
    end

    @q = params[:q]
    if @q
      @applications = Application.search @q, order: "date_scraped DESC", page: params[:page], per_page: per_page
      @applications.context[:panes] << ThinkingSphinx::Panes::ExcerptsPane
      @rss = search_applications_path(format: "rss", q: @q, page: nil)
    end
    @description = @q ? "Search: #{@q}" : "Search"

    respond_to do |format|
      format.html
      format.rss { render "api/index", format: :rss, layout: false, content_type: Mime::XML }
    end
  end

  def show
    # First check if there is a redirect
    redirect = ApplicationRedirect.find_by_application_id(params[:id])
    if redirect
      redirect_to id: redirect.redirect_application_id
      return
    end

    @application = Application.find(params[:id])
    @comments = @application.comments.visible.order(:updated_at)
    @nearby_count = @application.find_all_nearest_or_recent.size
    @comment = Comment.new
    # Required for new email alert signup form
    @alert = Alert.new(address: @application.address)

    if params[:with_councillors] == "true" && @theme == "default"
      @councillors = @application.authority.councillors.shuffle if @application.authority.councillors.any?
    end

    if params[:with_councillor_message] == "true" || params[:with_councillor_reply] == "true"
      @message_to_councillor = Comment.new(name: "Laurie Burdekin",
                                           text: "Hi Melissa, this development needs to be rethought out to suit the area and the community. This land was purchased from the original home owners to be used for a bypass and should never have been rezoned to accommodate a development such as this. We need you to reject this application at the council meeting.",
                                           updated_at: 5.hours.ago,
                                           id: "99")

      if params[:with_councillor_reply] == "true"
        @reply_from_councillor = { councillor: { name: "Melissa Brooks", party: "The Greens" },
                                   parent_comment_id: @message_to_councillor.id,
                                   text: "Thanks for your message Laurie. I’ll be sure to let the council know about your views at the upcoming council meeting on 12th November. Best wishes, Melissa Brooks",
                                   updated_at: 1.hours.ago,
                                   id: "100",
                                   authority_id: 1}
      end
    end

    respond_to do |format|
      format.html
    end
  end

  def nearby
    # First check if there is a redirect
    redirect = ApplicationRedirect.find_by_application_id(params[:id])
    if redirect
      redirect_to id: redirect.redirect_application_id
      return
    end

    @sort = params[:sort]
    @rss = nearby_application_url(params.merge(format: "rss", page: nil))

    # TODO: Fix this hacky ugliness
    if request.format == Mime::HTML
      per_page = 30
    else
      per_page = Application.per_page
    end

    @application = Application.find(params[:id])
    case(@sort)
    when "time"
      @applications = @application.find_all_nearest_or_recent.paginate page: params[:page], per_page: per_page
    when "distance"
      @applications = Application.unscoped do
        @application.find_all_nearest_or_recent.paginate page: params[:page], per_page: per_page
      end
    else
      redirect_to sort: "time"
      return
    end

    respond_to do |format|
      format.html { render "nearby" }
      format.rss { render "api/index", format: :rss, layout: false, content_type: Mime::XML }
    end
  end
end
