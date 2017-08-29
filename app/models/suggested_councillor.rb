class SuggestedCouncillor < ActiveRecord::Base
  has_one :authority, through: :councillor_contribution
  belongs_to :councillor_contribution
  validates :councillor_contribution, :name, :email, presence: true
  validates_email_format_of :email, message: "must be a valid email address, e.g. jane@example.com"

  def popolo_id
    "#{councillor_contribution.authority.full_name.split.join("_").downcase}/#{self.name.split.join("_").downcase}"
  end

end
