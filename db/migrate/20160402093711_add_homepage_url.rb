class AddHomepageUrl < ActiveRecord::Migration
  def change
    add_column :authorities, :primary_url, :string
  end
end
