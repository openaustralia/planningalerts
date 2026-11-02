# frozen_string_literal: true

unless defined?(APP_VERSION)
  revision_path = File.join(Rails.root, "REVISION")
  APP_VERSION = if Rails.env.production? && File.size?(revision_path)
                  File.read(revision_path)[0..6]
                else
                  # A commit hash, as tag names make broken GitHub links. Blank where git
                  # can't find the repository, such as a worktree inside Docker
                  `git rev-parse --short HEAD 2>/dev/null`.strip
                end
end
