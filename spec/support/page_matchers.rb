# frozen_string_literal: true

# Smoke test matchers for a rendered page. Each works on a request spec's
# `response` or a feature spec's `page`:
#
#   expect(response).to have_site_layout
#   expect(page).to have_no_broken_internal_links
#   expect(page).to have_no_missing_assets
module PageMatchers
  # Stands in for Warden when checking routes, so links that need a signed-in
  # admin (such as /admin/jobs) count as routable. We only want to know a route
  # exists for the link, not whether this viewer may follow it.
  class AdminWarden
    Admin = Struct.new(:id) do
      def has_role?(_role) = true
    end

    def user(*) = Admin.new(1)
    def authenticate!(*) = user
  end

  SKIPPED_SCHEMES = %w[mailto tel javascript data].freeze

  def self.capybara_node(actual)
    Capybara.string(actual.respond_to?(:body) ? actual.body : actual.html)
  end

  def self.base_url(actual)
    actual.respond_to?(:current_url) ? actual.current_url : "http://www.example.com/"
  end

  # [method, url] for every link and form on the page
  def self.links(node)
    anchors = node.all("a[href]", visible: :all).map do |a|
      [a["data-turbo-method"] || a["data-method"] || "get", a["href"]]
    end
    forms = node.all("form[action]", visible: :all).map do |form|
      override = form.first("input[name='_method']", visible: :all, minimum: 0)
      [override&.value || form["method"] || "get", form["action"]]
    end
    anchors + forms
  end

  # Path of a link on our own site, or nil for external links and anchors
  def self.internal_path(href, base_url)
    return if href.blank? || href.start_with?("#")

    uri = URI.join(base_url, href)
    return if SKIPPED_SCHEMES.include?(uri.scheme)
    return unless uri.host == URI(base_url).host

    uri.path
  rescue URI::Error
    nil
  end

  def self.routable?(method, path)
    env = Rack::MockRequest.env_for("http://www.example.com#{path}", method: method.upcase)
    env["warden"] = AdminWarden.new
    request = ActionDispatch::Request.new(env)
    Rails.application.routes.router.recognize(request) do |route, _params|
      # Routes inside a `constraints` block (like the API hostname catch-all)
      # are only real matches when the constraint passes too
      return true if route.app.matches?(request)
    end
    false
  end

  # Local URLs of the stylesheets, scripts, icons and images the page loads
  def self.asset_urls(node)
    srcs = node.all("link[href], script[src], img[src], source[src]", visible: :all).map do |element|
      element["href"] || element["src"]
    end
    srcsets = node.all("img[srcset], source[srcset]", visible: :all).flat_map do |element|
      element["srcset"].split(",").map { |candidate| candidate.split.first }
    end
    srcs + srcsets
  end

  # A path is served if it's a file in public/, an asset Sprockets can find
  # (with or without its fingerprint), or a route such as the analytics proxy.
  # <link> also covers pages like rel="canonical" and RSS, which the route
  # check handles. Sprockets is mounted as a route under the assets prefix in
  # tests, so those paths must be real assets rather than just routable.
  def self.asset_exists?(path)
    return sprockets_asset?(path) if path.start_with?(assets_prefix)

    public_file?(path) || routable?("get", path)
  end

  def self.assets_prefix
    "#{Rails.application.config.assets.prefix}/"
  end

  def self.public_file?(path)
    file = Rails.public_path.join(path.delete_prefix("/")).expand_path
    file.to_s.start_with?(Rails.public_path.to_s) && file.file?
  end

  def self.sprockets_asset?(path)
    name = path.delete_prefix(assets_prefix)
    without_fingerprint = name.sub(%r{-\h{7,128}(?=\.[^./]+\z)}, "")
    [name, without_fingerprint].uniq.any? { |logical| Rails.application.assets.find_asset(logical) }
  end

  # { url => path } for assets served by this site, skipping CDN files
  def self.local_assets(actual)
    base = base_url(actual)
    asset_urls(capybara_node(actual)).index_with { |url| internal_path(url, base) }.compact
  end

  def self.broken_links(actual)
    base = base_url(actual)
    links(capybara_node(actual)).filter_map do |method, href|
      path = internal_path(href, base)
      "#{method.upcase} #{href}" if path && !routable?(method, path)
    end.uniq
  end
end

RSpec::Matchers.define :have_site_layout do
  match do |actual|
    node = PageMatchers.capybara_node(actual)
    @missing = {
      "main navigation (html body header nav[aria-label='Main'])" => "html body header nav[aria-label='Main']",
      "OAF footer (html body footer.oaf-footer)" => "html body footer.oaf-footer"
    }.reject { |_name, css| node.has_css?(css, visible: :all) }.keys
    @missing.empty?
  end

  failure_message { "expected page to have #{@missing.join(' and ')}" }
end

# Every real page loads our stylesheet and scripts, so a page with no local
# assets means something is wrong with the page or this check
RSpec::Matchers.define :have_no_missing_assets do
  match do |actual|
    assets = PageMatchers.local_assets(actual)
    @missing = assets.reject { |_url, path| PageMatchers.asset_exists?(path) }.keys
    @none_found = assets.empty?
    !@none_found && @missing.empty?
  end

  failure_message do
    if @none_found
      "expected the page to load at least one local stylesheet, script or image, but found none"
    else
      "expected every local asset to exist, but these are missing:\n  #{@missing.join("\n  ")}"
    end
  end
end

RSpec::Matchers.define :have_no_broken_internal_links do
  match do |actual|
    @broken = PageMatchers.broken_links(actual)
    @broken.empty?
  end

  failure_message do
    "expected no links without a matching route, but found:\n  #{@broken.join("\n  ")}"
  end
end
