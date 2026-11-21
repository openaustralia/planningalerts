# frozen_string_literal: true

require "spec_helper"

# A matcher that always passes would hide broken pages, so check these fail
# when they should.
describe PageMatchers, type: :request do
  def page_with(main)
    html = <<~HTML
      <html><head><link rel="stylesheet" href="/assets/tailwind.css"></head><body>
        <header><nav aria-label="Main"></nav></header>
        <main>#{main}</main>
        <footer class="oaf-footer"></footer>
      </body></html>
    HTML
    Struct.new(:body).new(html)
  end

  describe "have_site_layout" do
    it "passes a real page" do
      get about_path
      expect(response).to have_site_layout
    end

    it "fails without the main navigation and OAF footer" do
      expect(Struct.new(:body).new("<html><body><header></header></body></html>"))
        .not_to have_site_layout
    end
  end

  describe "have_no_missing_assets" do
    it "passes a real page" do
      get about_path
      expect(response).to have_no_missing_assets
    end

    it "accepts public files, fingerprinted assets, routes and CDN files" do
      expect(page_with(<<~HTML)).to have_no_missing_assets
        <link rel="icon" href="/favicon-32x32.png">
        <link rel="stylesheet" href="/assets/tailwind-0123456789abcdef.css">
        <script src="/assets/application.js"></script>
        <img src="/assets/logo.svg" srcset="/assets/logo.svg 1x, /apple-touch-icon.png 2x">
        <link rel="alternate" href="/about">
        <script src="https://cdn.example.org/missing.js"></script>
      HTML
    end

    it "fails on a missing public file" do
      expect(page_with('<link rel="icon" href="/no-such-icon.png">')).not_to have_no_missing_assets
    end

    it "fails on a missing fingerprinted asset" do
      expect(page_with('<script src="/assets/no-such-script-0123456789abcdef.js"></script>'))
        .not_to have_no_missing_assets
    end

    it "fails on a missing image in a srcset" do
      expect(page_with('<img src="/assets/logo.svg" srcset="/assets/no-such-image.png 2x">'))
        .not_to have_no_missing_assets
    end

    it "doesn't count files outside public/" do
      expect(page_with('<img src="/../Gemfile">')).not_to have_no_missing_assets
    end

    it "fails on a page with no local assets, so it can't pass by checking nothing" do
      html = "<html><body><script src=\"https://cdn.example.org/x.js\"></script></body></html>"
      expect(Struct.new(:body).new(html)).not_to have_no_missing_assets
    end

    it "names the missing asset" do
      expect { expect(page_with('<img src="/nope.png">')).to have_no_missing_assets }
        .to raise_error(RSpec::Expectations::ExpectationNotMetError, %r{/nope\.png})
    end
  end

  describe "have_no_broken_internal_links" do
    it "passes a real page" do
      get about_path
      expect(response).to have_no_broken_internal_links
    end

    it "ignores external links, anchors and email links" do
      expect(page_with(<<~HTML)).to have_no_broken_internal_links
        <a href="https://example.org/nope">x</a> <a href="#top">t</a> <a href="mailto:a@example.com">m</a>
      HTML
    end

    it "accepts redirects, query strings and admin-only tools" do
      expect(page_with(<<~HTML)).to have_no_broken_internal_links
        <a href="/donate">d</a> <a href="http://www.example.com/faq?x=1#y">q</a>
        <a href="/admin/jobs">j</a> <a href="/admin/flipper">f</a>
      HTML
    end

    it "accepts forms using the right method, including through _method" do
      expect(page_with(<<~HTML)).to have_no_broken_internal_links
        <form action="/contact_messages" method="post"></form>
        <form action="/profile/alerts/1" method="post"><input type="hidden" name="_method" value="delete"></form>
      HTML
    end

    it "fails on a link with no route, rather than matching the API hostname catch-all" do
      expect(page_with('<a href="/no/such/page">x</a>')).not_to have_no_broken_internal_links
    end

    it "fails on a form using the wrong method" do
      expect(page_with('<form action="/about" method="post"></form>')).not_to have_no_broken_internal_links
    end

    it "fails on the wrong method given through _method" do
      expect(page_with(<<~HTML)).not_to have_no_broken_internal_links
        <form action="/about" method="post"><input type="hidden" name="_method" value="delete"></form>
      HTML
    end

    it "fails on the wrong method given through data-turbo-method" do
      expect(page_with('<a href="/about" data-turbo-method="delete">x</a>')).not_to have_no_broken_internal_links
    end

    it "names the broken link" do
      expect { expect(page_with('<a href="/nope">x</a>')).to have_no_broken_internal_links }
        .to raise_error(RSpec::Expectations::ExpectationNotMetError, %r{GET /nope})
    end
  end
end
