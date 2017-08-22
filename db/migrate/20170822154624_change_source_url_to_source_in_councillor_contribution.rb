class ChangeSourceUrlToSourceInCouncillorContribution < ActiveRecord::Migration
  def change
    remove_column :councillor_contributions, :source_url, :string
    add_column :councillor_contributions, :source, :string
  end
end
