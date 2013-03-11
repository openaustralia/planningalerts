namespace :ts do
  # Make Thinking Sphinx play nicely with Foreman
  desc "Run searchd in the foreground"
  task :run_in_foreground => :environment do
    ts = ThinkingSphinx::Configuration.instance
    exec "#{ts.bin_path}#{ts.searchd_binary_name} --pidfile --config #{ts.config_file} --nodetach"
  end
end