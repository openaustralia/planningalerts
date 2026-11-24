# frozen_string_literal: true

require "spec_helper"

# What people see when a comment has the kinds of text real comments contain.
# The patterns were chosen from counts over production comments, and the text
# is made up. Checking the page means any change to how comments are cleaned
# and linked shows up here, wherever in the code that change is made.
describe "Comment formatting" do
  let(:application) { create(:geocoded_application) }

  # The comment's HTML with whitespace normalised, because a browser shows a
  # newline and a space the same way and so do people. A <br> and the edges of
  # a paragraph still count.
  def rendered_comment(text)
    create(:published_comment, application:, name: "Andrew Citizen", text:)
    visit application_path(application)
    page.find(".prose").native.inner_html
        .gsub(/\s+/, " ")
        .gsub(%r{\s*(<br>|</?p>)\s*}, '\1')
  end

  it "makes line breaks and blank lines from Windows line endings" do
    expect(rendered_comment("First line\r\nSecond line\r\n\r\nNew paragraph")).to eq(
      "<p>First line<br>Second line</p><p>New paragraph</p>"
    )
  end

  it "keeps simple formatting tags" do
    expect(rendered_comment("A <b>bold</b>, <i>italic</i>, <em>em</em> and <strong>strong</strong> word")).to eq(
      "<p>A <b>bold</b>, <i>italic</i>, <em>em</em> and <strong>strong</strong> word</p>"
    )
  end

  it "keeps bare angle brackets as text" do
    expect(rendered_comment("5 > 3 and 2 < 4")).to eq "<p>5 &gt; 3 and 2 &lt; 4</p>"
  end

  it "keeps an ampersand inside words and between words" do
    expect(rendered_comment("R&D, AT&T and Q&A & more")).to eq "<p>R&amp;D, AT&amp;T and Q&amp;A &amp; more</p>"
  end

  it "keeps quotes and apostrophes" do
    expect(rendered_comment(%(She said "no" and it's fine))).to eq %(<p>She said "no" and it's fine</p>)
  end

  it "keeps accents, curly quotes, dashes and emoji" do
    expect(rendered_comment("Café – naïve “quotes” 😀")).to eq "<p>Café – naïve “quotes” 😀</p>"
  end

  it "leaves asterisks and underscores alone" do
    expect(rendered_comment("*this* and **that** and _other_")).to eq "<p>*this* and **that** and _other_</p>"
  end

  it "links a web address" do
    expect(rendered_comment("See https://example.org/plans now")).to eq(
      %(<p>See <a href="https://example.org/plans" rel="nofollow">https://example.org/plans</a> now</p>)
    )
  end

  it "links an address that starts with www" do
    expect(rendered_comment("See www.example.org/plans now")).to eq(
      %(<p>See <a href="http://www.example.org/plans" rel="nofollow">www.example.org/plans</a> now</p>)
    )
  end

  it "leaves punctuation after a web address outside the link" do
    expect(rendered_comment("(see https://example.org/plans), and https://example.org/more.")).to eq(
      %(<p>(see <a href="https://example.org/plans" rel="nofollow">https://example.org/plans</a>), and ) +
      %(<a href="https://example.org/more" rel="nofollow">https://example.org/more</a>.</p>)
    )
  end

  it "keeps brackets that are part of a web address" do
    expect(rendered_comment("See https://example.org/Plan_(final) now")).to eq(
      %(<p>See <a href="https://example.org/Plan_(final)" rel="nofollow">https://example.org/Plan_(final)</a> now</p>)
    )
  end

  it "links an email address" do
    expect(rendered_comment("Write to jo@example.org please")).to eq(
      %(<p>Write to <a href="mailto:jo@example.org" rel="nofollow">jo@example.org</a> please</p>)
    )
  end
end
