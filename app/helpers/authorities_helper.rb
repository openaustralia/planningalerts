# typed: true
# frozen_string_literal: true

module AuthoritiesHelper
  def morph_url(authority)
    "https://morph.io/#{authority.morph_name}" if authority.morph_name.present?
  end

  def morph_watchers_url(authority)
    "#{morph_url(authority)}/watchers" if morph_url(authority)
  end

  def github_url(authority)
    "https://github.com/#{authority.morph_name}" if authority.morph_name.present?
  end

  def github_issues_url(authority)
    "#{github_url(authority)}/issues" if github_url(authority)
  end
end
