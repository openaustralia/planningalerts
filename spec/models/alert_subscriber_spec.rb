# frozen_string_literal: true

require "spec_helper"

RSpec.describe AlertSubscriber, type: :model do
  it "they have an email" do
    expect(AlertSubscriber.create(email: "elzia@example.org").email).to eql "elzia@example.org"
  end
end
