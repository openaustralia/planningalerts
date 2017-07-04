class CouncillorContribution < ActiveRecord::Base
  belongs_to :contributor
  belongs_to :authority
  has_many :suggested_councillors
end
