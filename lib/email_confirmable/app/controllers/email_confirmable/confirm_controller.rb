class EmailConfirmable::ConfirmController < ApplicationController
  def confirmed
    object = params[:resource].classify.constantize.find_by_confirm_id(params[:id])
    if object
      object.confirm!
      singular = params[:resource].singularize
      # This seems a bit long-winded. Is there a better way?
      instance_variable_set(("@" + singular).to_sym, object)
      render singular
    else
      render :text => "", :status => 404
    end
  end
end