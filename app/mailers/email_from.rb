# typed: true
# frozen_string_literal: true

module EmailFrom
  private

  def email_from
    "#{ENV['EMAIL_FROM_NAME']} <#{ENV['EMAIL_FROM_ADDRESS']}>"
  end
end
