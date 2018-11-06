class EmailBatch < ActiveRecord::Base
  scope :in_past_week, -> { where("created_at > ?", 7.days.ago) }

  def self.total_sent_in_past_week
    in_past_week.sum(:no_emails)
  end
end
