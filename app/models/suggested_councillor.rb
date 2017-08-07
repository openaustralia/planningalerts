class SuggestedCouncillor < ActiveRecord::Base
  has_one :authority, through: :councillor_contribution
  belongs_to :councillor_contribution
  validates :councillor_contribution, :name, :email, presence: true
  validates_email_format_of :email, message: "format seems not right.
  Does it follow the format of example@email.com?", unless: Proc.new{|c| c.email.blank?}
end
