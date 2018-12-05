class AddPopulation2017ToAuthorities < ActiveRecord::Migration[5.2]
  def change
    add_column :authorities, :population_2017, :integer
  end
end
