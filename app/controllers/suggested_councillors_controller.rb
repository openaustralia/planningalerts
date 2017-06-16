class SuggestedCouncillorsController < ApplicationController

  def new
    @suggested_councillor = SuggestedCuncillor.new
  end

end
