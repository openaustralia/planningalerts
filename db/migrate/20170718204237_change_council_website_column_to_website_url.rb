class ChangeCouncilWebsiteColumnToWebsiteUrl < ActiveRecord::Migration
  def change
    rename_column :authorities, :council_website, :website_url
  end
end
