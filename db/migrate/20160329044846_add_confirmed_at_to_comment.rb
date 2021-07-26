class AddConfirmedAtToComment < ActiveRecord::Migration[4.2]
  def change
    add_column :comments, :confirmed_at, :datetime
  end
end
