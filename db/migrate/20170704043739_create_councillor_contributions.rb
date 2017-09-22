class CreateCouncillorContributions < ActiveRecord::Migration
  def change
    create_table :councillor_contributions do |t|
      t.integer :contributor_id
      t.integer :authority_id

      t.timestamps null: false
    end
  end
end
