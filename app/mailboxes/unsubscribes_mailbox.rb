# typed: strict
# frozen_string_literal: true

# Handles the mailto: option of the List-Unsubscribe header on alert emails
# (RFC 2369). A mail client that can't make the one-click HTTP request sends an
# email to unsubscribe+<confirm_id>@planningalerts.org.au instead. The confirm_id
# is the same secret that is in the one-click URL.
class UnsubscribesMailbox < ApplicationMailbox
  extend T::Sig

  ADDRESS = T.let(/\Aunsubscribe\+([^@]+)@/i, Regexp)

  sig { void }
  def process
    alert = Alert.find_by(confirm_id:)
    alert.unsubscribe! if alert && !alert.unsubscribed?
  end

  private

  sig { returns(T.nilable(String)) }
  def confirm_id
    mail.recipients.each do |recipient|
      match = ADDRESS.match(recipient.to_s)
      return T.must(match[1]).downcase if match
    end
    nil
  end
end
