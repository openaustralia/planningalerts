# typed: strict
# frozen_string_literal: true

module DonationsHelper
  extend T::Sig

  sig { params(price: Integer).returns(Integer) }
  def price_in_cents(price)
    price * 100
  end
end
