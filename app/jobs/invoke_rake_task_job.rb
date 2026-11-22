# typed: strict
# frozen_string_literal: true

require "rake"
# Loading the tasks twice would give every task its actions twice. Check for
# one of our own tasks, since a gem may already have defined others.
Rails.application.load_tasks unless Rake::Task.task_defined?("db:stats")

# Fromhttps://github.com/sidekiq-cron/sidekiq-cron/issues/133#issuecomment-819909671
class InvokeRakeTaskJob
  extend T::Sig
  include Sidekiq::Job

  sig { params(args: T.untyped).void }
  def perform(args)
    Rake::Task[args["task"]].reenable
    Rake::Task[args["task"]].invoke(args["args"])
  end
end
