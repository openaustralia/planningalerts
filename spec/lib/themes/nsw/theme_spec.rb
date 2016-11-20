require 'spec_helper'

describe Themes::NSW::Theme do

  around do |test|
    with_theme_env 'nsw' do
      ThemeChooser.theme
      test.run
    end
  end

  it 'sets ssl_required? to false' do
    expect(described_class.new.ssl_required?).to be false
  end

  it 'sets the protocol to "http"' do
    expect(described_class.new.protocol).to eq "http"
  end

  it "sets the asset paths to its asset dirs" do
    expected = Rails.root.join("lib",
                               "themes",
                               "nsw",
                               "assets",
                               "stylesheets").to_s
    expect(described_class.new.asset_paths).to eq([expected])
  end

  it 'sets the view path' do
    expected = Rails.root.join("lib",
                               "themes",
                               "nsw",
                               "views")
    expect(described_class.new.view_path).to eq(expected)
  end

end
