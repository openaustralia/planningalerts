class AddSourceUrlToCouncilorContributions < ActiveRecord::Migration
  def change
    add_column :councillor_contributions, :source_url, :string
  end
end
