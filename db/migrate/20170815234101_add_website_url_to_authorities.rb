class AddWebsiteUrlToAuthorities < ActiveRecord::Migration
  def change
    add_column :authorities, :website_url, :string
  end
end
