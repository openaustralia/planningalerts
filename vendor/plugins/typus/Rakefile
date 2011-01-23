require 'rubygems'
require 'rake/testtask'
require 'rake/rdoctask'

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "typus/version"

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the typus plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Build the gem.'
task :build do
  system "gem build typus.gemspec"
end

desc 'Build and release the gem.'
task :release => :build do
  version = Typus::VERSION
  system "git tag v#{version}"
  system "git push origin v#{version}"
  system "gem push pkg/typus-#{version}.gem"
  system "git clean -fd"
  system "gem push typus-#{version}"
end

desc 'Generate specdoc-style documentation from tests'
task :specs do

  puts 'Started'
  timer, count = Time.now, 0

  File.open('SPECDOC', 'w') do |file|
    Dir.glob('test/**/*_test.rb').each do |test|
      test =~ /.*\/([^\/].*)_test.rb$/
      file.puts "#{$1.gsub('_', ' ').capitalize} should:" if $1
      File.read(test).map { |line| /test_(.*)$/.match line }.compact.each do |spec|
        file.puts "- #{spec[1].gsub('_', ' ')}"
        sleep 0.001; print '.'; $stdout.flush; count += 1
      end
      file.puts
    end
  end

  puts <<-MSG
\nFinished in #{Time.now - timer} seconds.
#{count} specifications documented.
  MSG

end
