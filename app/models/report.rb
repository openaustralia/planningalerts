# frozen_string_literal: true

class Report < ApplicationRecord
  # TODO: This should be null: false in the schema, right?
  belongs_to :comment

  validates :name, presence: true
  validates :email, presence: true
  validates :details, presence: true
  validates_email_format_of :email, on: :create
end
