class MakeCouncilReferenceUniqueInApplications < ActiveRecord::Migration[5.2]
  def change
    add_index :applications, [:authority_id, :council_reference], unique: true
  end
end
