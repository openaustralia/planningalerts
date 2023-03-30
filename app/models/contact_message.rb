# typed: strict
# frozen_string_literal: true

class ContactMessage < ApplicationRecord
  belongs_to :user
end
