class ChangeAlertConfirmedNilToFalse < ActiveRecord::Migration
  def change
    Alert.where(confirmed: nil).find_each do |alert|
      alert.update(confirmed: false)
    end
  end
end
