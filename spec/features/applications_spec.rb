# frozen_string_literal: true

require "spec_helper"

describe "Applications pages" do
  include Devise::Test::IntegrationHelpers

  # rubocop:disable RSpec/NoExpectationExample
  it "renders the page", js: true do
    create(:geocoded_application,
           address: "24 Bruce Road Glenbrook",
           description: "A lovely house")
    create(:geocoded_application,
           address: "351 Pacific Hwy, Coffs Harbour NSW 2450",
           description: "S4.55(1A) - Modification - alignment of 20 cabins rotated - positions of duplex cabins swapped with other cabins - 2 bedroom cabins changed to a duplex cabin 1 bedroom & studio")

    sign_in create(:confirmed_user, tailwind_theme: true, name: "Jane Ng")
    visit applications_path
    page.percy_snapshot("Most recent applications across Australia")
  end
  # rubocop:enable RSpec/NoExpectationExample
end
