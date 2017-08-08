class SuggestedCouncillor < ActiveRecord::Base
  has_one :authority, through: :councillor_contribution
  belongs_to :councillor_contribution
  validates :councillor_contribution, :name, :email, presence: true
  validates_email_format_of :email, message: "Email must be a valid email address, e.g. jane@example.com"
end
