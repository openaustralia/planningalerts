class LayarController < ApplicationController
  # Ugly polluting namespace kind of nastiness
  include ActionView::Helpers::TextHelper

  def getpoi
    @applications = Application.near([params[:lat].to_f, params[:lon].to_f], params[:radius].to_f / 1000, units: :km).paginate(page: params[:pageKey], per_page: 10)
    layar_applications = @applications.map do |a|
      lines = word_wrap(a.description, line_width: 35).split("\n")
      line4 = truncate(lines[2..-1].join(" "), length: 35) if lines[2..-1]
      {
        actions: [{ label: "More info", uri: application_url(utm_medium: "ar", utm_source: "layar", id: a.id) }],
        attribution: nil,
        distance: a.distance.to_f * 1000,
        id: a.id,
        # TODO: Fix the hardwired domain name and path
        imageURL: "http://www.planningalerts.org.au/images/layar/icon_100x75.png",
        lat: a.lat * 1000000,
        lon: a.lng * 1000000,
        line2: lines[0],
        line3: lines[1],
        line4: line4,
        title: a.address.squish,
        # We're using a custom icon for the spots
        type: 1
      }
    end
    # TODO: Make layer name configurable
    result = { hotspots: layar_applications, radius: params[:radius].to_i, errorCode: 0, errorString: nil, layer: "planningalertsaustralia" }
    if @applications.current_page < @applications.total_pages
      result[:morePages] = true
      result[:nextPageKey] = @applications.current_page + 1
    end
    render json: result
  end

  private

  # Disable ssl redirects on this controller
  def ssl_required?
    false
  end
end
