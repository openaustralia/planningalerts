# frozen_string_literal: true

class Contributor < ActiveRecord::Base
  has_many :councillor_contributions, dependent: :destroy
end
