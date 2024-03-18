# typed: strict
# frozen_string_literal: true

class NoRepliesMailbox < ApplicationMailbox
  extend T::Sig
  before_processing :check_auto_submitted, :check_precedence

  sig { void }
  def process
    ReplyToNoReplyMailer.reply(mail).deliver_now
  end

  private

  # Checks that this isn't some kind of automatically generated email
  sig { void }
  def check_auto_submitted
    auto_submitted = mail.header["Auto-Submitted"]
    return unless auto_submitted && auto_submitted.value != "no"

    bounced!
  end

  sig { void }
  def check_precedence
    precedence = mail.header["Precedence"]
    # See https://datatracker.ietf.org/doc/html/rfc3834#section-7
    return unless precedence && %w[list junk bulk].include?(precedence.value)

    bounced!
  end
end
