module CouncillorContributionsHelper
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
