# typed: true

module ApplicationsHelper
  sig { returns(T.nilable(User)) }
  def current_user; end
end
