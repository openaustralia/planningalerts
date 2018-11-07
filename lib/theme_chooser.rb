# frozen_string_literal: true

class ThemeChooser
  THEMES = [DefaultTheme.new].freeze

  def self.create(theme)
    r = THEMES.find { |t| t.theme == theme }
    raise "Unknown theme #{theme}" if r.nil?
    r
  end
end
