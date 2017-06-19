class SuggestedCouncillor < ActiveRecord::Base
  belongs_to :authority
  validates :authority_id, :name, :email, presence: true
end
