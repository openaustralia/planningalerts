class CouncillorContribution < ActiveRecord::Base
  belongs_to :contributor
  belongs_to :authority
  has_many :suggested_councillors, inverse_of: :councillor_contribution
  accepts_nested_attributes_for :suggested_councillors, reject_if: :all_blank
  validates_associated :suggested_councillors

  def attribution(with_email: false)
    if contributor
      if with_email
        "#{contributor.name} ( #{contributor.email} )"
      else
        contributor.name
      end
    else
      "Anonymous"
    end
  end

  def to_csv
    attributes = %w{
      name start_date end_date exective council council_website id email image
      party source ward phone_mobile
    }

    CSV.generate(headers: true) do |csv|
      csv << attributes

      suggested_councillors.each do |s|
        csv << [
          s.name, nil, nil, nil, authority.full_name, nil, s.popolo_id,
          s.email, nil, nil, nil, nil, nil, nil
        ]
      end
    end
  end
end
