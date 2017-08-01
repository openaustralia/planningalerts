class SuggestedCouncillor < ActiveRecord::Base
  has_one :authority, through: :councillor_contribution
  belongs_to :councillor_contribution
  validates :email, :name, presence: true
  validates_email_format_of :email
end
