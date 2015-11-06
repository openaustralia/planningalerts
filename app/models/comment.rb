class Comment < ActiveRecord::Base
  belongs_to :application
  belongs_to :councillor
  has_many :reports
  validates_presence_of :name, :text, :address

  acts_as_email_confirmable
  scope :visible, -> { where(confirmed: true, hidden: false) }
  scope :in_past_week, -> { where("created_at > ?", 7.days.ago) }

  scope :visible_with_unique_emails_for_date, ->(date) {
    visible.where("date(created_at) = ?", date).group(:email)
  }

  scope :by_first_time_commenters_for_date, ->(date) {
    visible_with_unique_emails_for_date(date)
    .select {|c| where("email = ? AND created_at < ?", c.email, c.created_at.to_date).empty? }
  }

  scope :by_returning_commenters_for_date, ->(date) {
    visible_with_unique_emails_for_date(date)
    .select {|c| where("email = ? AND created_at < ?", c.email, c.created_at.to_date).any? }
  }

  # Send the comment to the planning authority
  def after_confirm
    CommentNotifier.delay.notify_authority("default", self)
  end
end
