class AddScraperwikiNameToAuthorities < ActiveRecord::Migration[4.2]
  def self.up
    add_column :authorities, :scraperwiki_name, :string
  end

  def self.down
    remove_column :authorities, :scraperwiki_name
  end
end
