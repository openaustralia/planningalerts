class Reply < ActiveRecord::Base
  belongs_to :councillor
  belongs_to :comment
end
