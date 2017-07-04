class SuggestedCouncillor < ActiveRecord::Base
  has_one :authority, through: :councillor_contribution
  belongs_to :councillor_contribution
  validates :authority_id, :name, :email, presence: true
end

#add councillor_contribution id
#get rid of authrotiy id and contributor id
