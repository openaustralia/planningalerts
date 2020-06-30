# typed: strict
# frozen_string_literal: true

module CouncillorContributionsHelper
  extend T::Sig

  sig { params(authority: Authority).returns(String) }
  def link_to_or_website_text_for(authority)
    link_to_if(
      authority.website_url.present?,
      "#{authority.full_name} website",
      authority.website_url,
      title: "Go to the #{authority.full_name} website.",
      target: "_blank"
    )
  end
end
