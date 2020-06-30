# typed: strict
# frozen_string_literal: true

module AuthoritiesHelper
  extend T::Sig

  sig { params(authority: Authority).returns(T.nilable(String)) }
  def morph_url(authority)
    "https://morph.io/#{authority.morph_name}" if authority.morph_name.present?
  end

  sig { params(authority: Authority).returns(T.nilable(String)) }
  def morph_watchers_url(authority)
    "#{morph_url(authority)}/watchers" if morph_url(authority)
  end

  sig { params(authority: Authority).returns(T.nilable(String)) }
  def github_url(authority)
    "https://github.com/#{authority.morph_name}" if authority.morph_name.present?
  end

  sig { params(authority: Authority).returns(T.nilable(String)) }
  def github_issues_url(authority)
    "#{github_url(authority)}/issues" if github_url(authority)
  end
end
