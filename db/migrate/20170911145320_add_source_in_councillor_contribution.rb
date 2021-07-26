class AddSourceInCouncillorContribution < ActiveRecord::Migration[4.2]
  def change
    add_column :councillor_contributions, :source, :string
  end
end
