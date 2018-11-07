# frozen_string_literal: true

class Reply < ActiveRecord::Base
  belongs_to :councillor
  belongs_to :comment

  validates :received_at, presence: true

  after_create do
    ReplyNotifier.notify_comment_author("default", self).deliver_later
  end
end
