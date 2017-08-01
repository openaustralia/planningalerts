class Contributor < ActiveRecord::Base
  has_many :suggested_councillors, through: :councillor_contributions
  has_many :councillor_contributions
end
