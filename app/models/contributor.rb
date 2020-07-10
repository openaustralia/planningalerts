# typed: strict
# frozen_string_literal: true

class Contributor < ApplicationRecord
  has_many :councillor_contributions, dependent: :restrict_with_exception
end
