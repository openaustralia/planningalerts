# typed: strict
# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :comment
  # Only newer reports have users attached to them
  belongs_to :user, optional: true

  validates :email, presence: true
  validates :details, presence: true
  validates_email_format_of :email, on: :create
end
