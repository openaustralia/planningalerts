class AddColumnReviewedInCouncillorContribution < ActiveRecord::Migration[4.2]
  def change
    add_column :councillor_contributions, :reviewed, :boolean, default: false
  end
end
