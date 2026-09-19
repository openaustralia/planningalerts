# frozen_string_literal: true

unless defined?(APP_VERSION)
  revision_path = File.join(Rails.root, "REVISION")
  APP_VERSION = if Rails.env.production? && File.size?(revision_path)
                  File.read(revision_path)[0..6]
                else
                  `git describe --always`
                end
end
