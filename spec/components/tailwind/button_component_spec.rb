# frozen_string_literal: true

require "spec_helper"
require "rails_helper"

RSpec.describe Tailwind::ButtonComponent, type: :component do
  it "renders the content" do
    render_inline(described_class.new(tag: :button, size: "lg", type: :primary)) { "Hello world!" }
    expect(page).to have_text "Hello world!"
  end

  it "renders a button tag" do
    render_inline(described_class.new(tag: :button, size: "lg", type: :primary)) { "Hello world!" }
    expect(page).to have_button
  end

  it "renders a large button" do
    render_inline(described_class.new(tag: :button, size: "lg", type: :primary)) { "Hello world!" }
    expect(page).to have_button(class: %w[px-4 py-2 text-lg])
  end

  it "renders an extra large button" do
    render_inline(described_class.new(tag: :button, size: "xl", type: :primary)) { "Hello world!" }
    expect(page).to have_button(class: %w[px-10 py-3 sm:py-4 text-xl])
  end

  it "renders a primary button in white on green" do
    render_inline(described_class.new(tag: :button, size: "xl", type: :primary)) { "Hello world!" }
    expect(page).to have_button(class: %w[text-white bg-green])
  end

  it "renders a secondary button in white on gray" do
    render_inline(described_class.new(tag: :button, size: "xl", type: :secondary)) { "Hello world!" }
    expect(page).to have_button(class: %w[text-white bg-warm-grey])
  end

  it "renders the text as semibold" do
    render_inline(described_class.new(tag: :button, size: "xl", type: :primary)) { "Hello world!" }
    expect(page).to have_button(class: "font-semibold")
  end

  it "renders an icon" do
    render_inline(described_class.new(tag: :button, size: "xl", type: :primary, icon: :trash)) { "Hello world!" }
    expect(page).to have_css("svg")
  end

  it "renders a link tag" do
    render_inline(described_class.new(tag: :a, size: "lg", type: :primary, href: "/foo")) { "Hello world!" }
    expect(page).to have_link(href: "/foo")
  end

  it "renders the link tag as inline-block" do
    render_inline(described_class.new(tag: :a, size: "lg", type: :primary, href: "/foo")) { "Hello world!" }
    expect(page).to have_link(class: "inline-block")
  end

  it "renders links to open new tabs" do
    render_inline(described_class.new(tag: :a, size: "lg", type: :primary, href: "/foo", open_in_new_tab: true)) { "Hello world!" }
    expect(page).to have_css("a[target='_blank'][rel='noopener']")
  end
end
