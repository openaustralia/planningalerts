# Disabling metric_fu because it depends on rcov which doesn't work on Ruby 1.9
# require 'metric_fu'
# MetricFu::Configuration.run do |config|
#   config.rcov[:test_files] = ['spec/**/*_spec.rb']
#   config.rcov[:rcov_opts] << "-Ispec" # Needed to find spec_helper
# end
