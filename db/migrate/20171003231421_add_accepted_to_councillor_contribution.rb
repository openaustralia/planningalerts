class AddAcceptedToCouncillorContribution < ActiveRecord::Migration
  def change
    add_column :councillor_contributions, :accepted, :boolean, default: false
  end
end
