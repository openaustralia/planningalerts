# typed: strict
# frozen_string_literal: true

# Records a release and deploy in Sentry after each successful deploy so
# issues can be tied to the deploy that introduced them.
#
# Runs locally on the deployer's machine (not the servers) because that's
# where the Sentry CLI and the full git history live. Org/project defaults
# come from the committed .sentryclirc; the auth token comes from each
# deployer's ~/.sentryclirc — see README "Sentry release tracking".
namespace :sentry do
  desc "Record the release and deploy in Sentry"
  task :release do
    run_locally do
      # CLI v4 renamed the binary from sentry-cli to sentry, so support both,
      # preferring v4 (https://cli.sentry.dev/migrating-from-v3/). A candidate
      # only counts if it exists AND is authenticated.
      #
      # The two CLIs report authentication differently. v4 has `auth status`;
      # v3 has no such command and reports it through `info`. Don't reach for
      # `sentry info` on v4: it exits non-zero whenever no default org/project
      # is configured, even when the token is fine, which made every deploy
      # skip the release (#2183).
      #
      # SSHKit's local backend execs commands directly rather than through a
      # shell, so a missing binary raises Errno::ENOENT instead of making
      # `test` return false. Treat it the same as an unauthenticated CLI.
      cli = %w[sentry sentry-cli].find do |candidate|
        test(candidate == "sentry" ? "sentry auth status" : "sentry-cli info")
      rescue Errno::ENOENT
        false
      end

      if cli.nil?
        warn <<~WARNING
          ********************************************************************
          WARNING: the Sentry CLI (sentry or sentry-cli) is not installed or
          not authenticated.

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

      # v3 reads org and project from the committed .sentryclirc. v4 ignores
      # that file, so read the values here and pass them on the command line,
      # which keeps .sentryclirc the single source of truth for both.
      sentryclirc = File.read(File.expand_path("../../../.sentryclirc", __dir__))
      org = sentryclirc[/^\s*org\s*=\s*(\S+)/, 1]
      project = sentryclirc[/^\s*project\s*=\s*(\S+)/, 1]

      begin
        # Associating commits requires the GitHub integration to be installed in
        # Sentry. If it isn't yet, warn but still finalize and record the deploy.
        commit_warning = "WARNING: #{cli} could not associate commits with release #{release} " \
                         "(is the GitHub integration installed in Sentry?). Continuing without commit data."
        if cli == "sentry"
          # v4 renamed command groups to singular, takes the release as an
          # <org>/<version> positional, and made the deploy environment a
          # positional argument.
          versioned = "#{org}/#{release}"
          execute :sentry, "release", "create", "--project", project, versioned
          warn commit_warning unless test("sentry release set-commits --auto #{versioned}")
          execute :sentry, "release", "finalize", versioned
          execute :sentry, "release", "deploy", versioned, environment
        else
          execute :"sentry-cli", "releases", "new", release
          warn commit_warning unless test("sentry-cli releases set-commits --auto #{release}")
          execute :"sentry-cli", "releases", "finalize", release
          execute :"sentry-cli", "deploys", "new", "--release", release, "-e", environment
        end
      rescue StandardError => e
        # Recording the release in Sentry is best-effort; the deploy itself
        # has already succeeded, so don't let a Sentry CLI failure fail it.
        warn "WARNING: recording release #{release} in Sentry failed (#{e.message}). " \
             "The deploy itself has still succeeded."
      end
    end
  end
end

after "deploy:finished", "sentry:release"
