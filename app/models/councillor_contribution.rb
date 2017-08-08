class CouncillorContribution < ActiveRecord::Base
  belongs_to :contributor
  belongs_to :authority
  has_many :suggested_councillors, inverse_of: :councillor_contribution
  accepts_nested_attributes_for :suggested_councillors, reject_if: :all_blank
  validates :suggested_councillors, length: {minimum: 1}
end
