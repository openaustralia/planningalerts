class CreateSuburbStatePostcodeColumns < ActiveRecord::Migration[4.2]
  def self.up
    change_table(:applications) do |t|
      t.string :suburb, limit: 50
      t.string :state, limit: 10
      t.string :postcode, limit: 4
    end
    Application.reset_column_information
    # Load all the applications and resave them to force the geocoder to save the address bits and pieces
    Application.all.each do |app|
      app.save!
    end
  end

  def self.down
    change_table(:applications) do |t|
      t.remove :suburb, :state, :postcode
    end
  end
end
