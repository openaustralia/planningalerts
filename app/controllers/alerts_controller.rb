# typed: true
# frozen_string_literal: true

class AlertsController < ApplicationController
  caches_page :statistics

  class NewParams < T::Struct
    const :address, T.nilable(String)
    const :email, T.nilable(String)
  end

  class AlertParams < T::Struct
    const :address, String
    const :email, String
  end

  class CreateParams < T::Struct
    const :alert, AlertParams
  end

  class ConfirmedParams < T::Struct
    const :id, String
  end

  class UnsubscribeParams < T::Struct
    const :id, String
  end

  class AreaParams < T::Struct
    const :id, String
    # TODO: Use an enum here?
    const :size, T.nilable(String)
  end

  def new
    typed_params = TypedParams[NewParams].new.extract!(params)
    @alert = Alert.new(typed_params.serialize)
    @set_focus_control = typed_params.address ? "alert_email" : "alert_address"
  end

  def create
    typed_params = TypedParams[CreateParams].new.extract!(params)
    @address = typed_params.alert.address
    @alert = BuildAlertService.call(
      email: typed_params.alert.email,
      address: @address,
      radius_meters: zone_sizes["l"]
    )

    render "new" if @alert.present? && !@alert.save
  end

  def confirmed
    typed_params = TypedParams[ConfirmedParams].new.extract!(params)
    @alert = Alert.find_by!(confirm_id: typed_params.id)
    @alert.confirm!
  end

  def unsubscribe
    typed_params = TypedParams[UnsubscribeParams].new.extract!(params)
    @alert = Alert.find_by(confirm_id: typed_params.id)
    @alert&.unsubscribe!
  end

  # TODO: Split this into two actions
  def area
    typed_params = TypedParams[AreaParams].new.extract!(params)
    @zone_sizes = zone_sizes
    @alert = Alert.find_by!(confirm_id: typed_params.id)
    if request.get? || request.head?
      @size = @zone_sizes.invert[@alert.radius_meters]
    else
      @alert.radius_meters = @zone_sizes[typed_params.size]
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
