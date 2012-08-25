class AddPopulation2011ToAuthorities < ActiveRecord::Migration
  def self.up
    add_column :authorities, :population_2011, :integer
  end

  def self.down
    remove_column :authorities, :population_2011
  end
end
