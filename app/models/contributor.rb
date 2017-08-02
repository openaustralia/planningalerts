class Contributor < ActiveRecord::Base
  has_many :councillor_contributions
end
