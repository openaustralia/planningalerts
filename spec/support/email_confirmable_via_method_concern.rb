require "spec_helper"
require "validates_email_format_of/rspec_matcher"

shared_examples_for "email_confirmable_via_method" do
  let(:model) { described_class }
  let(:model_name_for_factory_girl) { model.to_s.underscore.to_sym }

  it "has a public method 'email'" do
    object = VCR.use_cassette('planningalerts') do
      build(model_name_for_factory_girl)
    end

    expect(object.public_methods.include?(:email)).to be true
  end

  it "has a public method #email that returns a valid email address" do
    object = VCR.use_cassette('planningalerts') do
      build(model_name_for_factory_girl)
    end

    expect(ValidatesEmailFormatOf::validate_email_format(object.email)).to be nil
  end

  describe "confirm_id" do
    let(:object) do
      VCR.use_cassette('planningalerts') { create(model_name_for_factory_girl) }
    end

    it "is a string" do
      expect(object.confirm_id).to be_instance_of(String)
    end

    it "is not the same for two different objects" do
      another_object = VCR.use_cassette('planningalerts') do
        create(model_name_for_factory_girl)
      end

      expect(object.confirm_id).to_not eq another_object.confirm_id
    end

    it "only includes hex characters and is exactly twenty characters long" do
      expect(object.confirm_id).to match(/^[0-9a-f]{20}$/)
    end
  end

  describe "#after_create" do
    let(:object) do
      VCR.use_cassette('planningalerts') { build(model_name_for_factory_girl) }
    end

    it "should call the method to send the confirmation email" do
      expect(object).to receive(:send_confirmation_email)
      object.save
    end
  end
end
