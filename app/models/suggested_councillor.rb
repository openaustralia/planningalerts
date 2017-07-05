class SuggestedCouncillor < ActiveRecord::Base
  has_one :authority, through: :councillor_contribution
  belongs_to :councillor_contribution
  validates :name, :email, presence: true
end
