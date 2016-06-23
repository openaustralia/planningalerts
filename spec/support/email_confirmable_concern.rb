require "spec_helper"

shared_examples_for "email_confirmable" do
  let(:model) { described_class }
  let(:model_name_for_factory_girl) { model.to_s.underscore.to_sym }

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
