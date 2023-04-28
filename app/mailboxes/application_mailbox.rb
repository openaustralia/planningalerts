# typed: strict

class ApplicationMailbox < ActionMailbox::Base
  routing(/^do-not-reply@/ => :do_not_replies)
end
