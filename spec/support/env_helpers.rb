# frozen_string_literal: true

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
end
