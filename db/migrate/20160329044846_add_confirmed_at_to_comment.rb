class AddConfirmedAtToComment < ActiveRecord::Migration
  def change
    add_column :comments, :confirmed_at, :datetime
  end
end
