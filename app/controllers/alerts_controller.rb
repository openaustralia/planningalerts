# frozen_string_literal: true

class AlertsController < ApplicationController
  caches_page :statistics

  def new
    @alert = Alert.new(address: params[:address], email: params[:email])
    @set_focus_control = params[:address] ? "alert_email" : "alert_address"
  end

  def create
    @address = params[:alert][:address]
    @alert = BuildAlertService.new(
      Alert.new(
        email: params[:alert][:email],
        address: @address,
        radius_meters: zone_sizes["l"]
      )
    ).parse

    render "new" if @alert.present? && !@alert.save
  end

  def confirmed
    @alert = Alert.find_by!(confirm_id: params[:id])
    @alert.confirm!
  end

  def unsubscribe
    @alert = Alert.find_by(confirm_id: params[:id])
    @alert&.unsubscribe!
  end

  def area
    @zone_sizes = zone_sizes
    @alert = Alert.find_by!(confirm_id: params[:id])
    if request.get?
      @size = @zone_sizes.invert[@alert.radius_meters]
    else
      @alert.radius_meters = @zone_sizes[params[:size]]
      @alert.save!
      render "area_updated"
    end
  end

  private

  def zone_sizes
    {
      "s" => Rails.application.config.planningalerts_small_zone_size,
      "m" => Rails.application.config.planningalerts_medium_zone_size,
      "l" => Rails.application.config.planningalerts_large_zone_size
    }
  end
end
