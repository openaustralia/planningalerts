class AddLastScraperRunLogToAuthorities < ActiveRecord::Migration
  def self.up
    add_column :authorities, :last_scraper_run_log, :text
  end

  def self.down
    remove_column :authorities, :last_scraper_run_log
  end
end
