# typed: strict
# frozen_string_literal: true

module RepliesHelper
  extend T::Sig

  sig { params(reply: Reply).returns(String) }
  def reply_path(reply)
    application_path(reply.comment.application, anchor: "reply#{reply.id}")
  end
end
