# typed: false
# frozen_string_literal: true

module EmailFrom
  extend T::Sig

  private

  sig { returns(String) }
  def email_from
    "#{ENV['EMAIL_FROM_NAME']} <#{ENV['EMAIL_FROM_ADDRESS']}>"
  end
end
