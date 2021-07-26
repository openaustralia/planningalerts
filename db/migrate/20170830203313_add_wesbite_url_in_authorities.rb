class AddWesbiteUrlInAuthorities < ActiveRecord::Migration[4.2]
  def change
    add_column :authorities, :website_url, :string
  end
end
