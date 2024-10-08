# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for dynamic methods in `DeviseMailer`.
# Please instead update this file by running `bin/tapioca dsl DeviseMailer`.


class DeviseMailer
  class << self
    sig { params(record: ::User, token: ::String, opts: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def confirmation_instructions(record, token, opts = T.unsafe(nil)); end

    sig { params(record: T.untyped, opts: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def email_changed(record, opts = T.unsafe(nil)); end

    sig { params(record: T.untyped, opts: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def password_change(record, opts = T.unsafe(nil)); end

    sig { params(record: ::User, token: ::String, opts: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def reset_password_instructions(record, token, opts = T.unsafe(nil)); end

    sig { params(record: ::User, token: ::String, opts: T.untyped).returns(::ActionMailer::MessageDelivery) }
    def unlock_instructions(record, token, opts = T.unsafe(nil)); end
  end
end
