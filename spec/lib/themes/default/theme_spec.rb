require 'spec_helper'

describe Themes::Default::Theme do

  around do |test|
    with_modified_env THEME: 'default' do
      ThemeChooser.theme
      test.run
    end
  end

  it 'sets ssl_required? to true' do
    expect(described_class.new.ssl_required?).to be true
  end

  it 'sets the asset paths to an empty list' do
    expect(described_class.new.asset_paths).to eq([])
  end

  it 'sets the email_from value' do
    expect(described_class.new.email_from).to eq 'PlanningAlerts <contact@planningalerts.org.au>'
  end

end