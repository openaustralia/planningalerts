class AddAsgs2021ToAuthorities < ActiveRecord::Migration[7.0]
  def change
    add_column :authorities, :asgs_2021, :string
  end
end
