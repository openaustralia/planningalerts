# typed: strict
# frozen_string_literal: true

class AlertsController < ApplicationController
  extend T::Sig

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

  sig { void }
  def new
    typed_params = TypedParams[NewParams].new.extract!(params)
    @alert = T.let(Alert.new(typed_params.serialize), T.nilable(Alert))
    @set_focus_control = T.let(typed_params.address ? "alert_email" : "alert_address", T.nilable(String))
  end

  sig { void }
  def create
    typed_params = TypedParams[CreateParams].new.extract!(params)
    address = typed_params.alert.address
    @address = T.let(address, T.nilable(String))
    @alert = T.let(
      BuildAlertService.call(
        email: typed_params.alert.email,
        address: address,
        radius_meters: T.must(zone_sizes["l"])
      ),
      T.nilable(Alert)
    )

    render "new" if @alert.present? && !@alert.save
  end

  sig { void }
  def confirmed
    typed_params = TypedParams[ConfirmedParams].new.extract!(params)
    @alert = Alert.find_by!(confirm_id: typed_params.id)
    @alert.confirm!
  end

  sig { void }
  def unsubscribe
    typed_params = TypedParams[UnsubscribeParams].new.extract!(params)
    @alert = Alert.find_by(confirm_id: typed_params.id)
    @alert&.unsubscribe!
  end

  # TODO: Split this into two actions
  sig { void }
  def area
    typed_params = TypedParams[AreaParams].new.extract!(params)
    @zone_sizes = T.let(zone_sizes, T.nilable(T::Hash[String, Integer]))
    alert = Alert.find_by!(confirm_id: typed_params.id)
    @alert = T.let(alert, T.nilable(Alert))
    if request.get? || request.head?
      @size = T.let(zone_sizes.invert[alert.radius_meters], T.nilable(String))
    else
      # TODO: If we seperate this action into two then we won't need to use T.must here
      alert.radius_meters = T.must(zone_sizes[T.must(typed_params.size)])
      alert.save!
      render "area_updated"
    end
  end

  private

  sig { returns(T::Hash[String, Integer]) }
  def zone_sizes
    {
      "s" => Rails.application.config.planningalerts_small_zone_size,
      "m" => Rails.application.config.planningalerts_medium_zone_size,
      "l" => Rails.application.config.planningalerts_large_zone_size
    }
  end
end
