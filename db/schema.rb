# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120730024221) do

  create_table "alerts", :force => true do |t|
    t.string   "email",         :limit => 120, :null => false
    t.string   "address",       :limit => 120, :null => false
    t.datetime "last_sent"
    t.float    "lat",                          :null => false
    t.float    "lng",                          :null => false
    t.string   "confirm_id",    :limit => 20
    t.boolean  "confirmed"
    t.integer  "radius_meters",                :null => false
    t.string   "lga_name",      :limit => 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "api_statistics", :force => true do |t|
    t.string   "ip_address"
    t.datetime "query_time"
    t.text     "query"
    t.text     "user_agent"
  end

  create_table "applications", :force => true do |t|
    t.string    "council_reference", :limit => 50,   :null => false
    t.text      "address",                           :null => false
    t.text      "description"
    t.string    "info_url",          :limit => 1024
    t.string    "comment_url",       :limit => 1024
    t.integer   "authority_id",                      :null => false
    t.float     "lat"
    t.float     "lng"
    t.timestamp "date_scraped",                      :null => false
    t.date      "date_received"
    t.string    "suburb",            :limit => 50
    t.string    "state",             :limit => 10
    t.string    "postcode",          :limit => 4
    t.date      "on_notice_from"
    t.date      "on_notice_to"
    t.integer  "no_alerted"
  end

  add_index "applications", ["authority_id"], :name => "authority_id"
  add_index "applications", ["date_scraped"], :name => "index_applications_on_date_scraped"
  add_index "applications", ["lat", "lng"], :name => "index_applications_on_lat_and_lng"
  add_index "applications", ["lat"], :name => "index_applications_on_lat"
  add_index "applications", ["lng"], :name => "index_applications_on_lng"
  add_index "applications", ["postcode"], :name => "index_applications_on_postcode"
  add_index "applications", ["state"], :name => "index_applications_on_state"
  add_index "applications", ["suburb"], :name => "index_applications_on_suburb"

  create_table "authorities", :force => true do |t|
    t.string  "full_name",  :limit => 200, :null => false
    t.string  "short_name", :limit => 100, :null => false
    t.string  "feed_url"
    t.boolean "disabled"
    t.string  "state",      :limit => 20
    t.string  "email"
  end

  add_index "authorities", ["short_name"], :name => "short_name_unique", :unique => true

  create_table "comments", :force => true do |t|
    t.text     "text"
    t.string   "email"
    t.string   "name"
    t.integer  "application_id"
    t.string   "confirm_id"
    t.boolean  "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.boolean  "hidden",         :default => false, :null => false
  end

  create_table "rails_admin_histories", :force => true do |t|
    t.string   "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_histories_on_item_and_table_and_month_and_year"

  create_table "reports", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "details"
    t.integer  "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stats", :force => true do |t|
    t.string  "key",   :limit => 25, :null => false
    t.integer "value",               :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  add_foreign_key "applications", "authorities", :name => "applications_authority_id_fk"

end
