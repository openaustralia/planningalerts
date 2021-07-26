class RemoveShortenedUrls < ActiveRecord::Migration[4.2]
  def self.up
    remove_column :applications, :info_tinyurl
    remove_column :applications, :comment_tinyurl
  end

  def self.down
    add_column :applications, :info_tinyurl, :string, limit: 50
    add_column :applications, :comment_tinyurl, :string, limit: 50
  end
end
