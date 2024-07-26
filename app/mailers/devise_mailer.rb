# typed: strict
# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  extend T::Sig

  sig { params(record: User, token: String, opts: T.untyped).returns(T.untyped) }
  def confirmation_instructions(record, token, opts = {})
    headers["X-Cuttlefish-Disable-Css-Inlining"] = "true"
    attachments.inline["illustration.png"] = Rails.root.join("app/assets/images/illustration/confirmation.png").read
    super
  end

  sig { params(record: User, token: String, opts: T.untyped).returns(T.untyped) }
  def reset_password_instructions(record, token, opts = {})
    headers["X-Cuttlefish-Disable-Css-Inlining"] = "true"
    attachments.inline["illustration.png"] = Rails.root.join("app/assets/images/illustration/reset-password.png").read
    super
  end

  sig { params(record: User, token: String, opts: T.untyped).returns(T.untyped) }
  def unlock_instructions(record, token, opts = {})
    headers["X-Cuttlefish-Disable-Css-Inlining"] = "true"
    super
  end
end
