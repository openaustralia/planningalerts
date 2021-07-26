class CreateSuggestedCouncillors < ActiveRecord::Migration[4.2]
  def change
    create_table :suggested_councillors do |t|
      t.string :name
      t.string :email
      t.integer :authority_id

      t.timestamps null: false
    end
  end
end
