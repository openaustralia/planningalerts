class SuggestedCouncillor < ActiveRecord::Base
  belongs_to :authority
  belongs_to :contributor
  accepts_nested_attributes_for :contributor
  validates :authority_id, :name, :email, presence: true
end
