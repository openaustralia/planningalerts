# This migration adds the optional `object_changes` column, in which PaperTrail
# will store the `changes` diff for each update event. See the readme for
# details.
# Also convert existing object column to json as well
class AddObjectChangesToVersions < ActiveRecord::Migration[7.1]
  def change
    add_column :versions, :object_changes, :json
    # We don't have any data in there now so we can just delete things
    remove_column :versions, :object, :text
    add_column :versions, :object, :json
  end
end
