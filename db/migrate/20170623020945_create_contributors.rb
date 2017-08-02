class CreateContributors < ActiveRecord::Migration
  def change
    create_table :contributors do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
