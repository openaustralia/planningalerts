# typed: true
# frozen_string_literal: true

module DonationsHelper
  def price_in_cents(price)
    price * 100
  end
end
