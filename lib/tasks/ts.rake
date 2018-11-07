namespace :ts do
  desc "Run Thinking Sphinx in the foreground (for something like foreman)"
  task run_in_foreground: ["ts:stop", "ts:index"] do
    config = ThinkingSphinx::Configuration.instance
    controller = config.controller
    pid = fork

    unless pid
      exec "#{controller.bin_path}#{controller.searchd_binary_name} --pidfile --config #{config.configuration_file} --nodetach"
    end

    Signal.trap("TERM") { Process.kill("TERM", pid) }
    Signal.trap("INT")  { Process.kill("INT", pid) }
    Process.wait(pid)
  end
end
