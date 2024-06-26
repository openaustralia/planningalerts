# frozen_string_literal: true

# You can preview the mails by browsing to http://localhost:3000/rails/mailers

require "factory_bot_rails"

class AuthorityPreview < ActionMailer::Preview
  def notify_authority
    comment = Comment.new(
      application: Application.new(
        id: 2,
        council_reference: "27-B/6",
        address: "20 Illawarra Road Marrickville 2204",
        description: "Erection of a bouncy castle",
        authority: Authority.new(
          full_name: "Inner West Council",
          email: "hello@innerwest.nsw.gov.au"
        )
      ),
      user: User.new(
        email: "foo@bar.com"
      ),
      text: "I really don't like inflatable things",
      name: "Martha",
      address: "18 Illawarra Road"
    )

    CommentMailer.notify_authority(comment)
  end
end
