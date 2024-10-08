# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `AlertMailer`.
# Please instead update this file by running `bin/tapioca dsl AlertMailer`.


class AlertMailer
  class << self
    sig do
      params(
        alert: ::Alert,
        applications: T::Array[::Application],
        comments: T::Array[::Comment]
      ).returns(::ActionMailer::MessageDelivery)
    end
    def alert(alert:, applications: T.unsafe(nil), comments: T.unsafe(nil)); end
  end
end
