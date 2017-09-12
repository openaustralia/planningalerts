class AddColumnReviewedInCouncillorContribution < ActiveRecord::Migration
  def change
    add_column :councillor_contributions, :reviewed, :boolean, default: false
  end
end
