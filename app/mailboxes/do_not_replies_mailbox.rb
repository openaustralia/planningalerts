# typed: strict
# frozen_string_literal: true

class DoNotRepliesMailbox < ApplicationMailbox
  extend T::Sig

  sig { void }
  def process
    ReplyToDoNotReplyMailer.reply(mail).deliver_now
  end
end
