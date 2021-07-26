class CreateContributors < ActiveRecord::Migration[4.2]
  def change
    create_table :contributors do |t|
      t.string :name
      t.string :email

      t.timestamps null: false
    end
  end
end
