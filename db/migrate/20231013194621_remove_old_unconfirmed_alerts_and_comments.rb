class RemoveOldUnconfirmedAlertsAndComments < ActiveRecord::Migration[7.0]
  def up
    Alert.where(confirmed: false).destroy_all
    Comment.skip_counter_culture_updates do
      Comment.where("confirmed IS NULL OR confirmed = false").destroy_all      
    end
  end

  def down
  end
end
