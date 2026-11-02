# typed: true

# Both come from the controller through helper_method (Devise and Pundit)
module ApplicationsHelper
  sig { returns(T.nilable(User)) }
  def current_user; end

  sig { params(record: T.untyped).returns(T.untyped) }
  def policy(record); end
end
