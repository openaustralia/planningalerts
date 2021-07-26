class CreateCouncillorContributions < ActiveRecord::Migration[4.2]
  def change
    create_table :councillor_contributions do |t|
      t.integer :contributor_id
      t.integer :authority_id

      t.timestamps null: false
    end
  end
end
