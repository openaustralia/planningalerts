# frozen_string_literal: true

class Report < ApplicationRecord
  belongs_to :comment

  validates :name, presence: true
  validates :email, presence: true
  validates :details, presence: true
  validates_email_format_of :email, on: :create
end
