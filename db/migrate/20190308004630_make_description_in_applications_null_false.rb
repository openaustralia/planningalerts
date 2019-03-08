class MakeDescriptionInApplicationsNullFalse < ActiveRecord::Migration[5.2]
  def change
    # There are application records with both description: nil and description: ""
    # Both of these are not currently allowed by the model validation but we don't
    # want to throw away these records. So, we're going to convert nil values
    # to "" and make the column null: false
    reversible do |dir|
      dir.up do
        Application.where(description: nil).update_all(description: "")
      end
      dir.down do
        Application.where(description: "").update_all(description: nil)
      end
    end
    change_column_null :applications, :description, false
  end
end
