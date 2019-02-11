# frozen_string_literal: true

class Reply < ApplicationRecord
  # TODO: Both of these below should be null: false in the schema, right?
  belongs_to :councillor
  belongs_to :comment

  validates :received_at, presence: true

  after_create do
    ReplyMailer.notify_comment_author(self).deliver_later
  end
end
