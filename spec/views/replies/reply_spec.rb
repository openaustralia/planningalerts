require "spec_helper"

describe "replies/_reply" do
  it "renders linebreak formatting into html" do
    reply = VCR.use_cassette("planningalerts") do
      create(
        :reply,
        text: "Thanks for your comment.\n\nI agree.\n\nBest wishes,\nLouise Councillor"
      )
    end

    render reply

    expect(rendered).to include(
      "<p>Thanks for your comment.</p>\n\n<p>I agree.</p>\n\n<p>Best wishes,\n<br />Louise Councillor</p>"
    )
  end

  it "doesn’t include any nasty javascript" do
    reply = VCR.use_cassette("planningalerts") do
      create(
        :reply,
        text: "
          <a href=\"javascript:document.location='http://www.google.com/'\">A nasty link</a>
          <script type='text/javascript'>alert('danger danger');</script>
        "
      )
    end

    render reply

    expect(rendered).to include("<a>A nasty link</a>")
    expect(rendered).to_not include(
      "<script type='text/javascript'>alert('danger danger');</script>"
    )
  end
end
