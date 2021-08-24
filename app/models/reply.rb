# typed: strict
# frozen_string_literal: true

class Reply < ApplicationRecord
  extend T::Sig

  belongs_to :councillor
  belongs_to :comment

  validates :received_at, presence: true
  after_create :notify_comment_author

  private

  sig { void }
  def notify_comment_author
    ReplyMailer.notify_comment_author(self).deliver_later
  end
end
