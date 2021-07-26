class AddIndexToApplicationRedirects < ActiveRecord::Migration[4.2]
  def change
    add_index :application_redirects, :application_id
  end
end
