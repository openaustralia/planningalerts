# frozen_string_literal: true

require "spec_helper"

# runWithFallback is the inline helper from app/views/application/_script_fallback.html.erb
# that every Alpine expression depending on a separately loaded script goes
# through. See #2193.
#
# These drive it directly rather than through Alpine, because the real failure
# is a blocked asset request and the javascript driver here is headless Firefox,
# which gives us no way to block one. The fallback writes to the page instead of
# returning a value, so the assertions can be ordinary Capybara ones.
#
# Note the Sentry loader is only included in production and only for people
# rather than crawlers, so window.Sentry is undefined throughout. Every example
# here therefore also covers the helper not falling over without it.
describe "Missing script fallback" do
  before do
    visit root_path
  end

  it "runs the fallback when the function it needs was never defined", :js do
    page.execute_script(<<~JS)
      runWithFallback(
        () => aFunctionFromAScriptThatNeverLoaded(),
        () => { document.body.insertAdjacentHTML("beforeend", "<p>the fallback ran</p>") }
      );
    JS

    expect(page).to have_content("the fallback ran")
  end

  it "runs the fallback when the function loaded but failed at runtime", :js do
    page.execute_script(<<~JS)
      runWithFallback(
        () => Promise.reject(new Error("maps.googleapis.com is blocked")),
        () => { document.body.insertAdjacentHTML("beforeend", "<p>the fallback ran</p>") }
      );
    JS

    expect(page).to have_content("the fallback ran")
  end

  it "leaves a successful call alone", :js do
    page.execute_script(<<~JS)
      runWithFallback(
        () => document.body.insertAdjacentHTML("beforeend", "<p>the real thing ran</p>"),
        () => { document.body.insertAdjacentHTML("beforeend", "<p>the fallback ran</p>") }
      );
    JS

    expect(page).to have_content("the real thing ran")
    expect(page).to have_no_content("the fallback ran")
  end

  # MapWithRadiusComponent awaits the result and expects the fallback's return
  # value, so a failure has to resolve rather than reject or hang.
  it "resolves to whatever the fallback returned, so callers can await it", :js do
    page.execute_script(<<~JS)
      runWithFallback(
        () => aFunctionFromAScriptThatNeverLoaded(),
        () => null
      ).then((result) => {
        document.body.insertAdjacentHTML("beforeend", "<p>resolved to " + result + "</p>");
      });
    JS

    expect(page).to have_content("resolved to null")
  end
end
