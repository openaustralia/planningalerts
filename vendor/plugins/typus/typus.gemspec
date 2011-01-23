# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "typus/version"

Gem::Specification.new do |s|

  s.name = "typus"
  s.version = Typus::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ["Francesc Esplugas"]
  s.email = ["francesc@intraducibles.com"]
  s.homepage = "http://labs.intraducibles.com/projects/typus"
  s.summary = "Effortless backend interface for Ruby on Rails applications. (Admin scaffold generator.)"
  s.description = "Awesone admin scaffold generator for Ruby on Rails applications."

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project = "typus"

  s.files = Dir.glob("**/*")
  s.require_path = "lib"

end
