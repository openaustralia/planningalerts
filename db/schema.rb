# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100421063127) do

  create_table "alerts", :force => true do |t|
    t.string   "email",            :limit => 120, :null => false
    t.string   "address",          :limit => 120, :null => false
    t.datetime "last_sent"
    t.float    "lat",                             :null => false
    t.float    "lng",                             :null => false
    t.string   "confirm_id",       :limit => 20
    t.boolean  "confirmed"
    t.integer  "area_size_meters",                :null => false
  end

  create_table "applications", :force => true do |t|
    t.string   "council_reference", :limit => 50,   :null => false
    t.text     "address",                           :null => false
    t.text     "description"
    t.string   "info_url",          :limit => 1024
    t.string   "comment_url",       :limit => 1024
    t.integer  "authority_id",                      :null => false
    t.float    "lat"
    t.float    "lng"
    t.datetime "date_scraped",                      :null => false
    t.date     "date_received"
    t.string   "suburb",            :limit => 50
    t.string   "state",             :limit => 10
    t.string   "postcode",          :limit => 4
    t.date     "on_notice_from"
    t.date     "on_notice_to"
  end

  add_index "applications", ["authority_id"], :name => "authority_id"
  add_index "applications", ["date_scraped"], :name => "index_applications_on_date_scraped"
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
  end

  add_index "authorities", ["short_name"], :name => "short_name_unique", :unique => true

  create_table "stats", :force => true do |t|
    t.string  "key",   :limit => 25, :null => false
    t.integer "value",               :null => false
  end

  add_foreign_key "applications", "authorities", :name => "applications_authority_id_fk"

end
