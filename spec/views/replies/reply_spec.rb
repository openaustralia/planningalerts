require 'spec_helper'

describe "replies/_reply" do
  it "formats line breaks into paragraphs" do
    reply = VCR.use_cassette('planningalerts') do
      create(
        :reply,
        text: "Thanks for your comment.\n\nI agree.\n\nBest wishes,\nLouise Councillor"
      )
    end

    render reply

    expect(rendered).to include(
"<p>Thanks for your comment.</p>

<p>I agree.</p>

<p>Best wishes,
<br />Louise Councillor</p>"
    )
  end
end
