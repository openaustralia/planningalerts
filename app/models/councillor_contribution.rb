# typed: false
# frozen_string_literal: true

require "csv"
class CouncillorContribution < ApplicationRecord
  belongs_to :contributor, optional: true
  belongs_to :authority, optional: true
  has_many :suggested_councillors, dependent: :restrict_with_exception, inverse_of: :councillor_contribution
  accepts_nested_attributes_for :suggested_councillors, reject_if: :all_blank
  accepts_nested_attributes_for :contributor, reject_if: :all_blank
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
    attributes = %w[
      name
      start_date
      end_date
      executive
      council
      council_website
      id
      email
      image
      party
      source
      ward
    ]

    CSV.generate(headers: true) do |csv|
      csv << attributes

      suggested_councillors.each do |s|
        csv << [
          s.name,
          nil,
          nil,
          nil,
          authority.full_name,
          authority.website_url,
          s.popolo_id,
          s.email,
          nil,
          nil,
          source,
          nil
        ]
      end
    end
  end
end
