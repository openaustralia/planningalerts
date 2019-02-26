class RemoveApiStatisticsTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :api_statistics do |t|
      t.string "ip_address"
      t.datetime "query_time"
      t.text "query"
      t.text "user_agent"
      t.integer "user_id"
      t.index ["query_time"], name: "index_api_statistics_on_query_time"
      t.index ["user_id"], name: "index_api_statistics_on_user_id"
    end
  end
end
