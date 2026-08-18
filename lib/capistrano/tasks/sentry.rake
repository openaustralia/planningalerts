# typed: strict
# frozen_string_literal: true

# Records a release and deploy in Sentry after each successful deploy so
# issues can be tied to the deploy that introduced them.
#
# Runs locally on the deployer's machine (not the servers) because that's
# where sentry-cli and the full git history live. Org/project defaults come
# from the committed .sentryclirc; the auth token comes from each deployer's
# ~/.sentryclirc — see README "Sentry release tracking".
namespace :sentry do
  desc "Record the release and deploy in Sentry"
  task :release do
    run_locally do
      # SSHKit's local backend execs commands directly rather than through a
      # shell, so a missing binary raises Errno::ENOENT instead of making
      # `test` return false. Treat it the same as an unauthenticated CLI.
      sentry_cli_usable = begin
        test("sentry-cli info")
      rescue Errno::ENOENT
        false
      end

      unless sentry_cli_usable
        warn <<~WARNING
          ********************************************************************
          WARNING: sentry-cli is not installed or not authenticated.

          This deploy was NOT recorded as a release in Sentry, so issues
          won't be linked to it. The deploy itself has still succeeded.

          To fix this for future deploys, see the "Sentry release tracking"
          section of the README.
          ********************************************************************
        WARNING
        next
      end

      # Matches the release auto-detected by the Ruby SDK from the REVISION file
      release = fetch(:current_revision)
      environment = fetch(:stage).to_s

      begin
        execute :"sentry-cli", "releases", "new", release
        # Associating commits requires the GitHub integration to be installed in
        # Sentry. If it isn't yet, warn but still finalize and record the deploy.
        unless test("sentry-cli releases set-commits --auto #{release}")
          warn "WARNING: sentry-cli could not associate commits with release #{release} " \
               "(is the GitHub integration installed in Sentry?). Continuing without commit data."
        end
        execute :"sentry-cli", "releases", "finalize", release
        execute :"sentry-cli", "deploys", "new", "--release", release, "-e", environment
      rescue StandardError => e
        # Recording the release in Sentry is best-effort; the deploy itself
        # has already succeeded, so don't let a sentry-cli failure fail it.
        warn "WARNING: recording release #{release} in Sentry failed (#{e.message}). " \
             "The deploy itself has still succeeded."
      end
    end
  end
end

after "deploy:finished", "sentry:release"
