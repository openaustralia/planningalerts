class Reply < ActiveRecord::Base
  belongs_to :councillor
  belongs_to :comment

  validates :received_at, presence: true

  after_create do
    ReplyNotifier.delay.notify_comment_author("default", self)
  end
end
