require 'spec_helper'

describe Themes::Base do

  it 'sets ssl_required? to true' do
    expect(described_class.new.ssl_required?).to be true
  end

  it 'sets the protocol to "https"' do
    expect(described_class.new.protocol).to eq 'https'
  end

end