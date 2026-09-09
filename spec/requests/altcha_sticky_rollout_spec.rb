# frozen_string_literal: true

require "spec_helper"

# A form is rendered on one request and checked on another. If Flipper answered
# differently between the two, somebody would be shown a form with no widget and
# then told their answer was missing. This is what makes a percentage rollout to
# logged-out people safe.
describe "ALTCHA sticky rollout" do
  include Devise::Test::IntegrationHelpers

  # Enough visitors that a 50% gate would almost certainly split them if it were
  # deciding afresh each time.
  def widget_shown?
    get new_user_registration_path
    response.body.include?("altcha-widget")
  end

  context "with a percentage gate on a logged-out visitor" do
    before { Flipper.enable_percentage_of_actors(:altcha, 50) }

    it "gives the same person the same answer on every request" do
      answers = Array.new(10) { widget_shown? }

      expect(answers.uniq.length).to eq 1
    end
  end

  # The :admins group is no use for trying this out on the protected forms:
  # every one of them is a form only a logged-out person ever sees, and a
  # logged-out person has no roles. Roll out with a small percentage_of_actors
  # instead. These examples pin down that the group at least behaves itself when
  # a Visitor meets it.
  context "with the flag on for the admins group" do
    before { Flipper.enable_group(:altcha, :admins) }

    it "shows a logged-out visitor nothing rather than raising" do
      expect(widget_shown?).to be false
    end
  end
end
