# typed: strict
# frozen_string_literal: true

class NoRepliesMailbox < ApplicationMailbox
  extend T::Sig

  sig { void }
  def process
    ReplyToDoNotReplyMailer.reply(mail).deliver_now
  end
end
