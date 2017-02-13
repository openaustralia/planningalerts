class ThemeChooser

  def self.themes
    theme_classes = Dir.glob(Rails.root.join("lib", "themes", "**", "theme.rb"))
    theme_classes.each{ |theme_class| require theme_class }
    Themes::Base.subclasses.map{ |theme| theme.new }
  end

  def self.create(name)
    theme = themes.find{ |t| t.name == name }
    raise "Unknown theme #{name}" unless theme
    theme
  end

  def self.theme()
    name = ENV['THEME'] || 'default'
    create(name)
  end

end
