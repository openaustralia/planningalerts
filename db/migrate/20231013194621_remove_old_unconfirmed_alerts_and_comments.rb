class RemoveOldUnconfirmedAlertsAndComments < ActiveRecord::Migration[7.0]
  def up
    Alert.where(confirmed: false).destroy_all
    Comment.where("confirmed IS NULL OR confirmed = false").destroy_all
  end

  def down
  end
end
