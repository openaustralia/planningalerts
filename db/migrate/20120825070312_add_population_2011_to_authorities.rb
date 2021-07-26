class AddPopulation2011ToAuthorities < ActiveRecord::Migration[4.2]
  def self.up
    add_column :authorities, :population_2011, :integer
  end

  def self.down
    remove_column :authorities, :population_2011
  end
end
