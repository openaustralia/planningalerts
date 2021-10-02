# typed: false
# frozen_string_literal: true

class EmailBatch < ApplicationRecord
  extend T::Sig

  scope(:in_past_week, -> { where("created_at > ?", 7.days.ago) })

  sig { returns(Integer) }
  def self.total_sent_in_past_week
    in_past_week.sum(:no_emails)
  end
end
