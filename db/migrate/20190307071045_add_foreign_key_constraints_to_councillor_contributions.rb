class AddForeignKeyConstraintsToCouncillorContributions < ActiveRecord::Migration[5.2]
  def change
    add_foreign_key :councillor_contributions, :contributors
    add_foreign_key :councillor_contributions, :authorities
  end
end
