class LayarController < ApplicationController
  def getpoi
    @applications = Application.paginate :origin => [params[:lat].to_f, params[:lon].to_f], :within => params[:radius].to_f / 1000,
      :page => params[:pageKey], :per_page => 10
  end
end
