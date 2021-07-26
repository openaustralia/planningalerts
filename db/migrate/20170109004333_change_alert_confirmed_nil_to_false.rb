class ChangeAlertConfirmedNilToFalse < ActiveRecord::Migration[4.2]
  def change
    Alert.where(confirmed: nil).find_each do |alert|
      alert.update(confirmed: false)
    end
  end
end
