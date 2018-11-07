# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :livereload do
  watch(%r{app/views/.+\.(erb|haml|slim)$})
  watch(%r{app/helpers/.+\.rb$})
  watch(%r{public/.+\.(css|js|html)$})
  watch(%r{config/locales/.+\.yml$})
  watch(%r{stylesheets/.+\.(scss|sass)$})
  watch(%r{stylesheets/\w+/.+\.(scss|sass)$})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/(.+\.(css|js|html)).*}) { |m| "/assets/#{m[2]}" }
end

guard :rspec, cmd: "bin/rspec" do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }

  # Rails example
  watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^app/(.*)(\.erb|\.haml)$})                 { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/routing/#{m[1]}_routing_spec.rb", "spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  watch(%r{^spec/support/(.+)\.rb$})                  { "spec" }
  watch('config/routes.rb')                           { "spec/routing" }
  watch('config/routes.rb')                           { "spec/requests" }
  watch('app/controllers/application_controller.rb')  { "spec/controllers" }

  # Capybara request specs
  watch(%r{^app/views/(.+)/.*\.(erb|haml)$})          { "spec/features" }

  # Turnip features and steps
  watch(%r{^spec/acceptance/(.+)\.feature$})
  watch(%r{^spec/acceptance/steps/(.+)_steps\.rb$}) { |m| Dir[File.join("**/#{m[1]}.feature")][0] || 'spec/acceptance' }
end

guard :rubocop, all_on_start: false do
  watch(/.+\.rb$/)
end
