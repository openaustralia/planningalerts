class ThemeChooser

  def self.themes
    theme_classes = Dir.glob(Rails.root.join("lib", "themes", "**", "theme.rb"))
    theme_classes.each{ |theme_class| require theme_class }
    themes = [Themes::Default::Theme.new]
    Themes::Base.subclasses.each do |theme|
      themes.unshift theme.new unless theme == Themes::Default::Theme
    end
    themes
  end

  def self.create(theme)
    r = themes.find{|t| t.theme == theme}
    raise "Unknown theme #{theme}" if r.nil?
    r
  end

  def self.themer_from_request(request)
    themes.find{|t| t.recognise?(request)}
  end

end
