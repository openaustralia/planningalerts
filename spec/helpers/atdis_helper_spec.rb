# frozen_string_literal: true

require "spec_helper"

describe AtdisHelper do
  describe "#attribute_value" do
    it "customs display a time" do
      # TODO: Update atdis gem to not return datetime but use time instead
      value = DateTime.new(2001, 1, 1)
      Timecop.freeze(Time.utc(2002, 1, 1)) do
        expect(helper.attribute_value(value)).to eq(
          '<div class="value">' \
          '<time datetime="2001-01-01T00:00:00+00:00">January 01, 2001 00:00</time> ' \
          '(about 1 year ago)' \
          '</div>'
        )
      end
    end

    it "customs display a url" do
      value = URI.parse("https://foo.com")
      expect(helper.attribute_value(value)).to eq(
        '<div class="value"><a href="https://foo.com">https://foo.com</a></div>'
      )
    end

    it "customs display an rgeo point" do
      value = RGeo::Cartesian.preferred_factory.point(-122.3, 47.6)
      expect(helper.attribute_value(value)).to eq(
        '<div class="value">' \
        'POINT (-122.3 47.6)' \
        '<p>' \
        '<img alt="Map" src="https://maps.googleapis.com/maps/api/staticmap?maptype=roadmap&amp;markers=color%3Ared%7C47.6%2C-122.3&amp;size=300x150&amp;zoom=12" width="300" height="150" />' \
        '</p>' \
        '</div>'
      )
    end

    it "customs display nil" do
      value = nil
      expect(helper.attribute_value(value)).to eq(
        '<div class="value"><p class="quiet">absent or null</p></div>'
      )
    end

    it "displays a string" do
      value = "foo"
      expect(helper.attribute_value(value)).to eq(
        '<div class="value">foo</div>'
      )
    end
  end
end
