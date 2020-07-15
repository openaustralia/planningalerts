# typed: strict
# frozen_string_literal: true

class SuggestedCouncillor < ApplicationRecord
  extend T::Sig

  has_one :authority, through: :councillor_contribution
  belongs_to :councillor_contribution
  validates :councillor_contribution, :name, :email, presence: true
  validates_email_format_of :email, message: "must be a valid email address, e.g. jane@example.com"

  sig { returns(String) }
  def popolo_id
    "#{councillor_contribution.authority.full_name.split.join('_').downcase}/#{name.split.join('_').downcase}"
  end
end
