class AddPopulation2021ToAuthority < ActiveRecord::Migration[7.0]
  def change
    add_column :authorities, :population_2021, :integer
  end
end
