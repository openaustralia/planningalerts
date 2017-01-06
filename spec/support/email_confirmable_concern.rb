require "spec_helper"

shared_examples_for "email_confirmable" do
  let(:model) { described_class }
  let(:model_name_for_factory_girl) { model.to_s.underscore.to_sym }

  it "must have an email" do
    object = VCR.use_cassette('planningalerts') do
      build(model_name_for_factory_girl, email: nil)
    end

    expect(object).to_not be_valid
  end

  it "must have a valid email address" do
    object = VCR.use_cassette('planningalerts') do
      build(model_name_for_factory_girl, email: "diddle@")
    end

    expect(object).not_to be_valid
    expect(object.errors[:email]).to eq(["does not appear to be a valid e-mail address"])
  end

  # TODO: Is this just retesting the validates_email_format_of gem?
  it "must have an email address which includes a '@'" do
    object = VCR.use_cassette('planningalerts') do
      build(model_name_for_factory_girl, email: "diddle")
    end

    expect(object).not_to be_valid
    expect(object.errors[:email]).to eq(["does not appear to be a valid e-mail address"])
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
