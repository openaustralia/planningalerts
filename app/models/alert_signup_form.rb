class AlertSignupForm
  include ActiveModel::Model

  attr_accessor(:email, :address)
  attr_writer :address_for_placeholder

  def address_for_placeholder
    @address_for_placeholder || "1 Sowerby St, Goulburn, NSW 2580"
  end
end
