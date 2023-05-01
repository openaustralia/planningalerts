# typed: strict
# frozen_string_literal: true

class NoRepliesMailbox < ApplicationMailbox
  extend T::Sig
  before_processing :require_human

  sig { void }
  def process
    ReplyToNoReplyMailer.reply(mail).deliver_now
  end

  private

  # Checks that this isn't some kind of automatically generated email
  sig { void }
  def require_human
    auto_submitted = mail.header["Auto-Submitted"]
    return if auto_submitted.nil? || auto_submitted.value == "no"

    bounced!
  end
end
