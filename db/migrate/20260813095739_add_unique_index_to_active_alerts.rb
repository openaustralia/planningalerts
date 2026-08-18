# frozen_string_literal: true

class AddUniqueIndexToActiveAlerts < ActiveRecord::Migration[7.1]
  # Alert validates that a user can't have two subscribed alerts for the same
  # address, but nothing enforced that in the database. Two requests that both
  # ran the uniqueness check before either insert committed could each create an
  # alert, and once a pair like that existed every later save of either row
  # failed validation, even saves that only touched delivery timestamps. That
  # broke alert processing and the Cuttlefish delivery event webhook.
  #
  # Note that this only deduplicates subscribed alerts. Multiple unsubscribed
  # alerts for the same address are allowed on purpose, so that people can
  # subscribe and unsubscribe more than once, which is why the index is partial.
  def up
    # Keep the alert with the most delivery history in each group of duplicates,
    # falling back to the one created first, and unsubscribe the rest. Done in
    # SQL to avoid the model callbacks, which would try to geocode.
    ids = select_values(<<~SQL.squish)
      WITH ranked AS (
        SELECT id, row_number() OVER (
          PARTITION BY user_id, address
          ORDER BY last_sent DESC NULLS LAST, last_processed DESC NULLS LAST, id ASC
        ) AS position
        FROM alerts
        WHERE unsubscribed = false
      )
      UPDATE alerts
      SET unsubscribed = true,
          unsubscribed_at = now(),
          unsubscribed_by = 'duplicate',
          updated_at = now()
      WHERE id IN (SELECT id FROM ranked WHERE position > 1)
      RETURNING id
    SQL

    say(ids.empty? ? "No duplicate subscribed alerts to unsubscribe" : "Unsubscribed #{ids.count} duplicate alert(s): #{ids.join(', ')}")

    add_index :alerts, %i[user_id address], unique: true, where: "unsubscribed = false",
                                            name: "index_alerts_on_user_id_and_address_active"
  end

  # Only the index is reversed. The alerts unsubscribed above stay unsubscribed.
  def down
    remove_index :alerts, name: "index_alerts_on_user_id_and_address_active"
  end
end
