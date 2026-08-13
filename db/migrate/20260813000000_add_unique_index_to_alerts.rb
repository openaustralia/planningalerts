# frozen_string_literal: true

class AddUniqueIndexToAlerts < ActiveRecord::Migration[7.1]
  def up
    # Remove duplicate active alerts, keeping the oldest one per (address, user_id)
    execute <<~SQL
      DELETE FROM alerts
      WHERE unsubscribed = false
        AND id NOT IN (
          SELECT MIN(id) FROM alerts
          WHERE unsubscribed = false
          GROUP BY address, user_id
        )
    SQL

    add_index :alerts, %i[address user_id], unique: true, where: "unsubscribed = false",
                                            name: "index_alerts_on_address_and_user_id_active_unique"
  end

  def down
    remove_index :alerts, name: "index_alerts_on_address_and_user_id_active_unique"
  end
end
