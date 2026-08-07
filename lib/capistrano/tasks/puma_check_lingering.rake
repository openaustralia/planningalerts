# typed: strict
# frozen_string_literal: true

# Check if lingering is already set - warn if not.

namespace :puma do
  desc "Check lingering is already set"
  task :check_lingering do
    on roles(fetch(:puma_role)) do |host|
      linger_status = capture("loginctl show-user #{host.user} 2>/dev/null | grep Linger || true")

      if linger_status.include?("Linger=yes")
        info "OK: Linger is enabled for #{host.user}@#{host.hostname}."
      else
        warn "FATAL: Linger is NOT enabled for #{host.user}@#{host.hostname}! Run as root:"
        warn ""
        warn "    loginctl enable-linger #{host.user}"
        warn ""
        warn "Without this, #{host.user}'s systemd --user services (including Puma) will"
        warn "stop when their SSH session ends or the box reboots."
        warn ""
        raise "Linger not enabled for #{host.user}@#{host.hostname}!"
      end
    end
  end
end
