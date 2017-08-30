class AdminNoticeMailer < ActionMailer::Base
  def notice_for_councillor_contribution
    @admins =  User.where(admin: true)
    @admins.each do |admin|
      mail(to: admin.email, subject: "New councillor contribution", from: "example@email.com")
    end
  end
end
