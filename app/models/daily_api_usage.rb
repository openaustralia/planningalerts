# typed: strict
# frozen_string_literal: true

class DailyApiUsage < ApplicationRecord
  belongs_to :api_key
end
