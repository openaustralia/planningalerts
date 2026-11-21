# typed: strict
# frozen_string_literal: true

require "rake"
# Loading the tasks twice would give every task its actions twice
Rails.application.load_tasks if Rake::Task.tasks.empty?

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
