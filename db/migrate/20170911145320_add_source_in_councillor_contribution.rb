class AddSourceInCouncillorContribution < ActiveRecord::Migration
  def change
    add_column :councillor_contributions, :source, :string
  end
end
