class CouncillorContribution < ActiveRecord::Base
  belongs_to :contributor
  belongs_to :authority
  has_many :suggested_councillors, inverse_of: :councillor_contribution
  accepts_nested_attributes_for :suggested_councillors, reject_if: :all_blank
  validates_associated :suggested_councillors

  def authority_name
    authority.full_name
  end

  def attribution(with_email: false)
    if contributor
      if with_email && contributor.email
        "#{contributor.name} ( #{contributor.email} )"
      else
        contributor.name
      end
    else
      "Anonymous"
    end
  end
end
