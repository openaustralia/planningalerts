class SuggestedCouncillorsController < ApplicationController

  def new
    @suggested_councillor = SuggestedCouncillor.new
    @authority = Authority.find(params[:authority_id])
  end

  def create
    @suggested_councillor = SuggestedCouncillor.new(suggested_councillor_params)
    @authority = Authority.find(params[:authority_id])
    @suggested_councillor.authority= @authority

      if @suggested_councillor.save
        flash[:notice] = "Thank you"
        redirect_to authority_url(@authority.short_name_encoded)
      else
        render :new
      end
    end

private
  def suggested_councillor_params
    params.require(:suggested_councillor).permit(:name, :email)
  end

end
