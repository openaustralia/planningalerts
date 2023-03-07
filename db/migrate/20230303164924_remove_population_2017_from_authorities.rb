class RemovePopulation2017FromAuthorities < ActiveRecord::Migration[7.0]
  def change
    remove_column :authorities, :population_2017, :integer
  end
end
