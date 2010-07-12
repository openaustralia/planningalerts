class LayarController < ApplicationController
  def getpoi
    @applications = Application.paginate :origin => [params[:lat].to_f, params[:lon].to_f], :within => params[:radius].to_f / 1000,
      :page => params[:pageKey], :per_page => 10
    layar_applications = @applications.map do |a|
      {
        :actions => [],
        :attribution => nil,
        :distance => a.distance.to_f * 1000,
        :id => a.id,
        :imageURL => nil,
        :lat => a.lat,
        :lon => a.lng,
        :line2 => nil,
        :line3 => nil,
        :line4 => nil,
        :title => nil,
        :type => 0
      }
    end
    result = {:hotspots => layar_applications}
    render :json => result
  end
end
