# typed: strict
# frozen_string_literal: true

class IsEmailAddressBannedService
  extend T::Sig

  BANNED_TLDS = T.let(["fodiscomail.com", "elighmail.com", "mailinator.com"].freeze, T::Array[String])

  sig { returns(String) }
  attr_reader :email

  sig { params(email: String).returns(T::Boolean) }
  def self.call(email:)
    new(email: email).call
  end

  sig { params(email: String).void }
  def initialize(email:)
    @email = email
  end

  sig { returns(T::Boolean) }
  def call
    begin
      address = Mail::Address.new(email)
    rescue Mail::Field::IncompleteParseError
      return false
    end

    return false if address.domain.nil?

    tld = address.domain.split(".")[-2..]&.join(".")
    BANNED_TLDS.include?(tld)
  end
end
