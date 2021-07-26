class CreateApplicationRedirects < ActiveRecord::Migration[4.2]
  def change
    create_table :application_redirects do |t|
      t.integer :application_id
      t.integer :redirect_application_id

      t.timestamps
    end
  end
end
