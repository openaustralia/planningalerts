# typed: true
HealthCheck.setup do |config|
  # Don't do all the standard checks
  config.standard_checks = [ 'database' ]
end
