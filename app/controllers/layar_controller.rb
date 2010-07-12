class LayarController < ApplicationController
  # Ugly polluting namespace kind of nastiness
  include ActionView::Helpers::TextHelper
  
  def getpoi
    @applications = Application.paginate :origin => [params[:lat].to_f, params[:lon].to_f], :within => params[:radius].to_f / 1000,
      :page => params[:pageKey], :per_page => 10
    layar_applications = @applications.map do |a|
      lines = word_wrap(a.description, :line_width => 35).split("\n")
      line4 = truncate(lines[2..-1].join(" "), :length => 35) if lines[2..-1]
      {
        :actions => [],
        :attribution => nil,
        :distance => a.distance.to_f * 1000,
        :id => a.id,
        :imageURL => nil,
        :lat => a.lat,
        :lon => a.lng,
        :line2 => lines[0],
        :line3 => lines[1],
        :line4 => line4,
        :title => a.address.squish,
        :type => 0
      }
    end
    # TODO: Make layer name configurable
    result = {:hotspots => layar_applications, :radius => params[:radius].to_i, :errorCode => 0, :layer => "planningalertsaustralia"}
    if @applications.current_page < @applications.total_pages
      result[:morePages] = true
      result[:nextPageKey] = @applications.current_page + 1
    end
    render :json => result
  end
end
