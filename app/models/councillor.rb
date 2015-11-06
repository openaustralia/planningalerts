class Councillor < ActiveRecord::Base
  has_many :comments
  belongs_to :authority
end
