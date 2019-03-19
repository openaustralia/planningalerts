class AddCounterCacheToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :visible_comments_count, :integer, null: false, default: 0
    add_index :applications, :visible_comments_count
  end
end
