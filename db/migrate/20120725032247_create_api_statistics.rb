class CreateApiStatistics < ActiveRecord::Migration[4.2]
  def self.up
    create_table :api_statistics do |t|
      t.string :ip_address
      t.datetime :query_time
      t.text :query
    end
  end

  def self.down
    drop_table :api_statistics
  end
end
