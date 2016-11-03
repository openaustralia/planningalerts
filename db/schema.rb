# encoding: UTF-8
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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160824034142) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree

  create_table "alerts", force: true do |t|
    t.string   "email",          limit: 120,                     null: false
    t.string   "address",        limit: 120,                     null: false
    t.datetime "last_sent"
    t.float    "lat",            limit: 24,                      null: false
    t.float    "lng",            limit: 24,                      null: false
    t.string   "confirm_id",     limit: 20
    t.boolean  "confirmed"
    t.integer  "radius_meters",                                  null: false
    t.string   "lga_name",       limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unsubscribed",               default: false,     null: false
    t.datetime "last_processed"
    t.string   "theme",                      default: "default", null: false
  end

  add_index "alerts", ["email"], name: "index_alerts_on_email", using: :btree

  create_table "api_statistics", force: true do |t|
    t.string   "ip_address"
    t.datetime "query_time"
    t.text     "query"
    t.text     "user_agent"
    t.integer  "user_id"
  end

  add_index "api_statistics", ["query_time"], name: "index_api_statistics_on_query_time", using: :btree
  add_index "api_statistics", ["user_id"], name: "index_api_statistics_on_user_id", using: :btree

  create_table "application_redirects", force: true do |t|
    t.integer  "application_id"
    t.integer  "redirect_application_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "application_redirects", ["application_id"], name: "index_application_redirects_on_application_id", using: :btree

  create_table "applications", force: true do |t|
    t.string   "council_reference", limit: 50,   null: false
    t.text     "address",                        null: false
    t.text     "description"
    t.string   "info_url",          limit: 1024
    t.string   "comment_url",       limit: 1024
    t.integer  "authority_id",                   null: false
    t.float    "lat",               limit: 24
    t.float    "lng",               limit: 24
    t.datetime "date_scraped",                   null: false
    t.date     "date_received"
    t.string   "suburb",            limit: 50
    t.string   "state",             limit: 10
    t.string   "postcode",          limit: 4
    t.date     "on_notice_from"
    t.date     "on_notice_to"
    t.integer  "no_alerted"
  end

  add_index "applications", ["authority_id", "date_scraped"], name: "index_applications_on_authority_id_and_date_scraped", using: :btree
  add_index "applications", ["authority_id"], name: "authority_id", using: :btree
  add_index "applications", ["date_scraped"], name: "index_applications_on_date_scraped", using: :btree
  add_index "applications", ["lat", "lng", "date_scraped"], name: "index_applications_on_lat_and_lng_and_date_scraped", using: :btree
  add_index "applications", ["postcode"], name: "index_applications_on_postcode", using: :btree
  add_index "applications", ["state"], name: "index_applications_on_state", using: :btree
  add_index "applications", ["suburb"], name: "index_applications_on_suburb", using: :btree

  create_table "authorities", force: true do |t|
    t.string  "full_name",                    limit: 200,                 null: false
    t.string  "short_name",                   limit: 100,                 null: false
    t.boolean "disabled"
    t.string  "state",                        limit: 20
    t.string  "email"
    t.integer "population_2011"
    t.text    "last_scraper_run_log"
    t.string  "morph_name"
    t.boolean "write_to_councillors_enabled",             default: false, null: false
    t.string  "lga_name15"
    t.string  "superceded_by"
  end

  add_index "authorities", ["lga_name15"], name: "index_authorities_on_lga_name15", using: :btree
  add_index "authorities", ["short_name"], name: "short_name_unique", unique: true, using: :btree

  create_table "comments", force: true do |t|
    t.text     "text"
    t.string   "email"
    t.string   "name"
    t.integer  "application_id"
    t.string   "confirm_id"
    t.boolean  "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address"
    t.boolean  "hidden",         default: false,     null: false
    t.string   "theme",          default: "default", null: false
    t.integer  "councillor_id"
    t.datetime "confirmed_at"
    t.integer  "writeit_message_id"
  end

  add_index "comments", ["application_id"], name: "index_comments_on_application_id", using: :btree
  add_index "comments", ["confirm_id"], name: "index_comments_on_confirm_id", using: :btree
  add_index "comments", ["confirmed"], name: "index_comments_on_confirmed", using: :btree
  add_index "comments", ["hidden"], name: "index_comments_on_hidden", using: :btree

  create_table "councillors", force: true do |t|
    t.string   "name"
    t.string   "image_url"
    t.string   "party"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.integer  "authority_id"
    t.string   "popolo_id"
  end

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0
    t.integer  "attempts",   default: 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "email_batches", force: true do |t|
    t.integer  "no_emails"
    t.integer  "no_applications"
    t.integer  "no_comments"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "replies", force: true do |t|
    t.text     "text"
    t.datetime "received_at"
    t.integer  "comment_id"
    t.integer  "councillor_id"
    t.integer  "writeit_id"
  end

  add_index "replies", ["comment_id"], name: "index_replies_on_comment_id", using: :btree
  add_index "replies", ["councillor_id"], name: "index_replies_on_councillor_id", using: :btree

  create_table "reports", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.text     "details"
    t.integer  "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stats", force: true do |t|
    t.string  "key",   limit: 25, null: false
    t.integer "value",            null: false
  end

  create_table "subscriptions", force: true do |t|
    t.string   "email"
    t.string   "stripe_customer_id"
    t.string   "stripe_subscription_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "trial_started_at"
    t.string   "stripe_plan_id"
    t.text     "free_reason"
  end

  add_index "subscriptions", ["email"], name: "index_subscriptions_on_email", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                              default: "",    null: false
    t.string   "encrypted_password",     limit: 128, default: "",    null: false
    t.string   "password_salt",                      default: "",    null: false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reset_password_sent_at"
    t.boolean  "admin",                              default: false, null: false
    t.string   "api_key"
    t.string   "name"
    t.string   "organisation"
    t.boolean  "bulk_api",                           default: false, null: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "api_disabled",                       default: false
  end

  add_index "users", ["api_key"], name: "index_users_on_api_key", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vanity_conversions", force: true do |t|
    t.integer "vanity_experiment_id"
    t.integer "alternative"
    t.integer "conversions"
  end

  add_index "vanity_conversions", ["vanity_experiment_id", "alternative"], name: "by_experiment_id_and_alternative", using: :btree

  create_table "vanity_experiments", force: true do |t|
    t.string   "experiment_id"
    t.integer  "outcome"
    t.datetime "created_at"
    t.datetime "completed_at"
  end

  add_index "vanity_experiments", ["experiment_id"], name: "index_vanity_experiments_on_experiment_id", using: :btree

  create_table "vanity_metric_values", force: true do |t|
    t.integer "vanity_metric_id"
    t.integer "index"
    t.integer "value"
    t.string  "date"
  end

  add_index "vanity_metric_values", ["vanity_metric_id"], name: "index_vanity_metric_values_on_vanity_metric_id", using: :btree

  create_table "vanity_metrics", force: true do |t|
    t.string   "metric_id"
    t.datetime "updated_at"
  end

  add_index "vanity_metrics", ["metric_id"], name: "index_vanity_metrics_on_metric_id", using: :btree

  create_table "vanity_participants", force: true do |t|
    t.string  "experiment_id"
    t.string  "identity"
    t.integer "shown"
    t.integer "seen"
    t.integer "converted"
  end

  add_index "vanity_participants", ["experiment_id", "converted"], name: "by_experiment_id_and_converted", using: :btree
  add_index "vanity_participants", ["experiment_id", "identity"], name: "by_experiment_id_and_identity", using: :btree
  add_index "vanity_participants", ["experiment_id", "seen"], name: "by_experiment_id_and_seen", using: :btree
  add_index "vanity_participants", ["experiment_id", "shown"], name: "by_experiment_id_and_shown", using: :btree
  add_index "vanity_participants", ["experiment_id"], name: "index_vanity_participants_on_experiment_id", using: :btree

  add_foreign_key "applications", "authorities", :name => "applications_authority_id_fk"

end
