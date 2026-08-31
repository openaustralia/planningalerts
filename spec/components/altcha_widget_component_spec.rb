# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

RSpec.describe AltchaWidgetComponent, type: :component do
  # The component asks the controller whether this person should see a check,
  # so that a form can render it unconditionally.
  before { allow(vc_test_controller).to receive(:altcha_required?).and_return(required) }

  let(:required) { true }

  context "when this person should see a check" do
    it "renders the widget pointed at our own challenge endpoint" do
      render_inline(described_class.new)

      expect(page).to have_css("altcha-widget[challenge='/altcha/challenge']", visible: :all)
    end

    it "names the hidden field the controllers read" do
      render_inline(described_class.new)

      expect(page).to have_css("altcha-widget[name='altcha']", visible: :all)
    end

    it "explains what to do when javascript can't run" do
      render_inline(described_class.new)

      expect(page).to have_css("noscript", visible: :all)
      expect(page.native.to_html).to include("get in touch")
    end

    # The widget's own test attribute makes it report success while submitting a
    # payload with no challenge in it, which the server can never verify. It has
    # no business on a real page.
    it "is never in the widget's own test mode" do
      render_inline(described_class.new)

      expect(page).to have_no_css("altcha-widget[test]", visible: :all)
    end
  end

  context "when this person should not see a check" do
    let(:required) { false }

    it "renders no widget at all, so a form can ask for it unconditionally" do
      render_inline(described_class.new)

      expect(page).to have_no_css("altcha-widget", visible: :all)
      expect(page).to have_no_css("noscript", visible: :all)
    end
  end
end
