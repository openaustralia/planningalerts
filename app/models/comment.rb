class Comment < ActiveRecord::Base
  belongs_to :application
  has_many :reports
  validates_presence_of :name, :text, :address

  acts_as_email_confirmable
  scope :visible, -> { where(confirmed: true, hidden: false) }
  scope :in_past_week, -> { where("created_at > ?", 7.days.ago) }
  scope :visible_with_unique_emails_for_date, ->(date) {
    visible.where("date(created_at) = ?", date).to_a
    .uniq {|c| c.email}
  }
  scope :by_first_time_commenters_for_date, ->(date) {
    visible_with_unique_emails_for_date(date)
    .select {|c| where("email = ? AND created_at < ?", c.email, c.created_at.to_date).empty? }
  }

  # Send the comment to the planning authority
  def after_confirm
    CommentNotifier.delay.notify("default", self)
  end

  def self.count_of_returning_commenters_for_date(date)
    visible_with_unique_emails_for_date(date).count - by_first_time_commenters_for_date(date).count
  end
end
