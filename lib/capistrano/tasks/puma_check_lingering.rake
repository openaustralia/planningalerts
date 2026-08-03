# typed: strict
# frozen_string_literal: true

# Check if lingering is already set - warn if not.

namespace :puma do
  desc "Check lingering is already set"
  task :check_lingering do
    on roles(fetch(:puma_role)) do |role|
      puma_user = role.user

      linger_status = capture("loginctl show-user #{puma_user} 2>/dev/null | grep Linger || true")

      if linger_status.include?("Linger=yes")
        info "OK: Linger is enabled for #{puma_user} on #{host}."
      else
        warn "FATAL: Linger is NOT enabled for #{puma_user} on #{host}! Run as root:"
        warn ""
        warn "    loginctl enable-linger #{puma_user}"
        warn ""
        warn "Without this, #{puma_user}'s systemd --user services (including Puma) will"
        warn "stop when their SSH session ends or the box reboots."
        warn ""
        raise "Linger not enabled for #{puma_user} on #{host}"
      end
    end
  end
end
