# frozen_string_literal: true

# Comment text that exercises everything the comment formatting does: a bare
# web address to link, two paragraphs and a line break, tags the Sanitize gem
# keeps (b) and removes (script, div), and characters that need escaping.
# Used by the page and email specs so a sanitiser change shows up in each.
module CommentExamples
  WITH_MARKUP = <<~TEXT.chomp
    See the plans at https://example.org/plans & the <b>council's</b> report.
    It's a second line.

    A new paragraph <script>alert(1)</script><div>with a div</div> and 5 < 6.
  TEXT

  # The comment as rendered in a page or email: from the tag that opens its
  # first paragraph to the end of its last. The last match skips any copy in
  # an email's hidden preview text.
  def self.rendered(html)
    html.scan(%r{<p[^>]*>See the plans at.*?5 &lt; 6\.(?:</p>|<p[^>]*></p>)?}m).last
  end
end
