module EnvHelpers
  def writeit_config_variables
    { WRITEIT_BASE_URL: "http://writeit.ciudadanointeligente.org",
      WRITEIT_URL: "/api/v1/instance/1927/",
      WRITEIT_USERNAME: "henare",
      WRITEIT_API_KEY: "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" }
  end

  def with_modified_env(options, &block)
    ClimateControl.modify(options, &block)
  end

  def with_theme_env(theme, &block)
    env = Dotenv::Environment.new(ThemeChooser.create(theme).env_file)
    with_modified_env(env, &block)
  end
end
