# frozen_string_literal: true

require "spec_helper"

describe GeocodeService do
  let(:address) { "24 Bruce Road, Glenbrook, NSW 2773" }

  it "should delegate the result to GoogleGeocodeService" do
    result = double
    expect(GoogleGeocodeService).to receive(:call).with(address).and_return(result)
    expect(GeocodeService.call(address)).to eq result
  end
end
