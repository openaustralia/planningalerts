# typed: strict
# frozen_string_literal: true

require "fileutils"

namespace :db do
  desc "Database Stats"
  task stats: [:environment] do
    heading_fmt = "%-30s %8s %11s"
    row_fmt     = "%-30s %8d %8.1f MB"

    puts format(heading_fmt, "Table", "Count", "Size")
    puts format(heading_fmt, "-" * 30, "-" * 8, "-" * 11)

    conn = ActiveRecord::Base.connection

    sql = <<~SQL.squish
      SELECT s.relname, s.n_live_tup, pg_total_relation_size(s.relid) / 1024.0 / 1024.0
      FROM pg_stat_user_tables s
    SQL
    table_stats = conn.exec_query(sql).rows.to_h { |name, rows, mb| [name, [rows, mb]] }

    total_mb    = 0.0
    total_count = 0

    conn.tables.sort.each do |t|
      approx_count, mb = table_stats[t]

      count = if ENV["EXACT_COUNT"] || approx_count.to_i < 100
                conn.exec_query("SELECT COUNT(*) FROM #{t}").rows.first[0]
              else
                approx_count
              end

      total_mb    += mb.to_f
      total_count += count
      puts format(row_fmt, t, count, mb.to_f)
    end

    puts format(heading_fmt, "", "=" * 8, "=" * 11)
    puts format(row_fmt, "TOTAL", total_count, total_mb)
    puts "",
         "Status as of #{Time.new.utc}",
         ENV["EXACT_COUNT"] ? "(exact count)" : "(approximate count - set EXACT_COUNT=1 to get exact)"
  end
end
