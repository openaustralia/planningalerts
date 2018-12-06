class RemovePopulation2011FromAuthorities < ActiveRecord::Migration[5.2]
  def change
    remove_column :authorities, :population_2011, :integer
  end
end
