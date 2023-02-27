class AddWikidataIdToAuthorities < ActiveRecord::Migration[7.0]
  def change
    add_column :authorities, :wikidata_id, :string
  end
end
