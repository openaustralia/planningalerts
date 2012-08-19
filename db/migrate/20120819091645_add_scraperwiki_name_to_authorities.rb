class AddScraperwikiNameToAuthorities < ActiveRecord::Migration
  def self.up
    add_column :authorities, :scraperwiki_name, :string
  end

  def self.down
    remove_column :authorities, :scraperwiki_name
  end
end
