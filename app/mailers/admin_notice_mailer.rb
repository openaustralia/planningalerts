class AdminNoticeMailer < ActionMailer::Base
  def notice_for_councillor_contribution(councillor_contribution)
    @councillor_contribution = councillor_contribution
      mail(
      to: ENV["EMAIL_MODERATOR"],
      subject: "New councillor contribution",
      from: ENV["EMAIL_MODERATOR"])
    end
end
