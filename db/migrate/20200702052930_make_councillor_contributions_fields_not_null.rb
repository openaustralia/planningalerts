class MakeCouncillorContributionsFieldsNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :councillor_contributions, :authority_id, false
    change_column_null :councillor_contributions, :reviewed, false
    change_column_null :councillor_contributions, :accepted, false
  end
end
