# frozen_string_literal: true

class ApiStatistic < ApplicationRecord
  belongs_to :user, optional: true
end
