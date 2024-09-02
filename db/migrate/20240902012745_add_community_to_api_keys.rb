class AddCommunityToApiKeys < ActiveRecord::Migration[7.1]
  def change
    add_column :api_keys, :community, :boolean, default: false, null: false, comment: "used for a verified community use"
  end
end
