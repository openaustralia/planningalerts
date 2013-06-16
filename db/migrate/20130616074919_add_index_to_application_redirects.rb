class AddIndexToApplicationRedirects < ActiveRecord::Migration
  def change
    add_index :application_redirects, :application_id
  end
end
