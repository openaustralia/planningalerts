# typed: strict
# frozen_string_literal: true

class ContactMessage < ApplicationRecord
  include ActiveStorage::Attached::Model

  belongs_to :user, optional: true
  has_many_attached :attachments

  validates :email, :reason, :details, presence: true

  REASONS_LONG = T.let([
    "I'm having trouble signing up",
    "I can't find a development application",
    "I've stopped receiving alerts",
    "I have a privacy concern",
    "I want to change or delete a comment I made",
    "The address or map location is wrong",
    "I have a question about how Planning Alerts works",
    "I'm trying to reach council",
    "I want API access or commercial use",
    "Other, please specify below"
  ].freeze, T::Array[String])
end
