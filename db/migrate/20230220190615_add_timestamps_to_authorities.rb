class AddTimestampsToAuthorities < ActiveRecord::Migration[7.0]
  def change
    add_column :authorities, :created_at, :datetime
    add_column :authorities, :updated_at, :datetime
  end
end
