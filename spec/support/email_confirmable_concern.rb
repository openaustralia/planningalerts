# frozen_string_literal: true

require "spec_helper"

shared_examples_for "email_confirmable" do
  let(:model) { described_class }
  let(:model_name_for_factory_bot) { model.to_s.underscore.to_sym }

  it "must have an email" do
    object = VCR.use_cassette("planningalerts") do
      build(model_name_for_factory_bot, email: nil)
    end

    expect(object).not_to be_valid
  end

  it "must have a valid email address" do
    object = VCR.use_cassette("planningalerts") do
      build(model_name_for_factory_bot, email: "diddle@")
    end

    expect(object).not_to be_valid
    expect(object.errors[:email]).to eq(["does not appear to be a valid e-mail address"])
  end

  # TODO: Is this just retesting the validates_email_format_of gem?
  it "must have an email address which includes a '@'" do
    object = VCR.use_cassette("planningalerts") do
      build(model_name_for_factory_bot, email: "diddle")
    end

    expect(object).not_to be_valid
    expect(object.errors[:email]).to eq(["does not appear to be a valid e-mail address"])
  end

  describe "confirm_id" do
    let(:object) do
      VCR.use_cassette("planningalerts") { create(model_name_for_factory_bot) }
    end

    it "is a string" do
      expect(object.confirm_id).to be_instance_of(String)
    end

    it "is not the same for two different objects" do
      another_object = VCR.use_cassette("planningalerts") do
        create(model_name_for_factory_bot)
      end

      expect(object.confirm_id).not_to eq another_object.confirm_id
    end

    it "only includes hex characters and is exactly twenty characters long" do
      expect(object.confirm_id).to match(/^[0-9a-f]{20}$/)
    end
  end

  describe "#after_create" do
    let(:object) do
      VCR.use_cassette("planningalerts") { build(model_name_for_factory_bot) }
    end

    it "calls the method to send the confirmation email" do
      allow(object).to receive(:send_confirmation_email)
      object.save
      expect(object).to have_received(:send_confirmation_email)
    end
  end
end
