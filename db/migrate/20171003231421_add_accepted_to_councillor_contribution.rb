class AddAcceptedToCouncillorContribution < ActiveRecord::Migration[4.2]
  def change
    add_column :councillor_contributions, :accepted, :boolean, default: false
  end
end
