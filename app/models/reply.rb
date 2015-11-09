class Reply < ActiveRecord::Base
  belongs_to :councillor
  belongs_to :comment

  validates :received_at, presence: true
end
