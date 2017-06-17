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

ActiveRecord::Schema.define(version: 20170911153225) do

  create_table "active_admin_comments", force: :cascade do |t|
    t.string   "resource_id",   limit: 255,   null: false
    t.string   "resource_type", limit: 255,   null: false
    t.integer  "author_id",     limit: 4
    t.string   "author_type",   limit: 255
    t.text     "body",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace",     limit: 255
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id", using: :btree

  create_table "alert_subscribers", force: :cascade do |t|
    t.string   "email",      limit: 255, null: false
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "alert_subscribers", ["email"], name: "index_alert_subscribers_on_email", unique: true, using: :btree

  create_table "alerts", force: :cascade do |t|
    t.string   "address",             limit: 120,                     null: false
    t.datetime "last_sent"
    t.float    "lat",                 limit: 24,                      null: false
    t.float    "lng",                 limit: 24,                      null: false
    t.string   "confirm_id",          limit: 20
    t.boolean  "confirmed",                       default: false,     null: false
    t.integer  "radius_meters",       limit: 4,                       null: false
    t.string   "lga_name",            limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "unsubscribed",                    default: false,     null: false
    t.datetime "last_processed"
    t.string   "theme",               limit: 255, default: "default", null: false
    t.datetime "unsubscribed_at"
    t.integer  "alert_subscriber_id", limit: 4
  end

  add_index "alerts", ["alert_subscriber_id"], name: "index_alerts_on_alert_subscriber_id", using: :btree

  create_table "api_statistics", force: :cascade do |t|
    t.string   "ip_address", limit: 255
    t.datetime "query_time"
    t.text     "query",      limit: 65535
    t.text     "user_agent", limit: 65535
    t.integer  "user_id",    limit: 4
  end

  add_index "api_statistics", ["query_time"], name: "index_api_statistics_on_query_time", using: :btree
  add_index "api_statistics", ["user_id"], name: "index_api_statistics_on_user_id", using: :btree

  create_table "application_redirects", force: :cascade do |t|
    t.integer  "application_id",          limit: 4
    t.integer  "redirect_application_id", limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "application_redirects", ["application_id"], name: "index_application_redirects_on_application_id", using: :btree

  create_table "applications", force: :cascade do |t|
    t.string   "council_reference", limit: 50,    null: false
    t.text     "address",           limit: 65535, null: false
    t.text     "description",       limit: 65535
    t.string   "info_url",          limit: 1024
    t.string   "comment_url",       limit: 1024
    t.integer  "authority_id",      limit: 4,     null: false
    t.float    "lat",               limit: 24
    t.float    "lng",               limit: 24
    t.datetime "date_scraped",                    null: false
    t.date     "date_received"
    t.string   "suburb",            limit: 50
    t.string   "state",             limit: 10
    t.string   "postcode",          limit: 4
    t.date     "on_notice_from"
    t.date     "on_notice_to"
    t.integer  "no_alerted",        limit: 4
  end

  add_index "applications", ["authority_id", "date_scraped"], name: "index_applications_on_authority_id_and_date_scraped", using: :btree
  add_index "applications", ["authority_id"], name: "authority_id", using: :btree
  add_index "applications", ["date_scraped"], name: "index_applications_on_date_scraped", using: :btree
  add_index "applications", ["lat", "lng", "date_scraped"], name: "index_applications_on_lat_and_lng_and_date_scraped", using: :btree
  add_index "applications", ["postcode"], name: "index_applications_on_postcode", using: :btree
  add_index "applications", ["state"], name: "index_applications_on_state", using: :btree
  add_index "applications", ["suburb"], name: "index_applications_on_suburb", using: :btree

  create_table "authorities", force: :cascade do |t|
    t.string  "full_name",                    limit: 200,                   null: false
    t.string  "short_name",                   limit: 100,                   null: false
    t.boolean "disabled"
    t.string  "state",                        limit: 20
    t.string  "email",                        limit: 255
    t.integer "population_2011",              limit: 4
    t.text    "last_scraper_run_log",         limit: 65535
    t.string  "morph_name",                   limit: 255
    t.boolean "write_to_councillors_enabled",               default: false, null: false
    t.string  "website_url",                  limit: 255
  end

  add_index "authorities", ["short_name"], name: "short_name_unique", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.text     "text",               limit: 65535
    t.string   "email",              limit: 255
    t.string   "name",               limit: 255
    t.integer  "application_id",     limit: 4
    t.string   "confirm_id",         limit: 255
    t.boolean  "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address",            limit: 255
    t.boolean  "hidden",                           default: false,     null: false
    t.string   "theme",              limit: 255,   default: "default", null: false
    t.integer  "councillor_id",      limit: 4
    t.datetime "confirmed_at"
    t.integer  "writeit_message_id", limit: 4
  end

  add_index "comments", ["application_id"], name: "index_comments_on_application_id", using: :btree
  add_index "comments", ["confirm_id"], name: "index_comments_on_confirm_id", using: :btree
  add_index "comments", ["confirmed"], name: "index_comments_on_confirmed", using: :btree
  add_index "comments", ["hidden"], name: "index_comments_on_hidden", using: :btree

  create_table "contributors", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "councillor_contributions", force: :cascade do |t|
    t.integer  "contributor_id", limit: 4
    t.integer  "authority_id",   limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "source",         limit: 65535
  end

  create_table "councillors", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "image_url",    limit: 255
    t.string   "party",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",        limit: 255
    t.integer  "authority_id", limit: 4
    t.string   "popolo_id",    limit: 255
    t.boolean  "current",                  default: true, null: false
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   limit: 4,     default: 0
    t.integer  "attempts",   limit: 4,     default: 0
    t.text     "handler",    limit: 65535
    t.text     "last_error", limit: 65535
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by",  limit: 255
    t.string   "queue",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

  create_table "donations", force: :cascade do |t|
    t.string   "email",                  limit: 255, null: false
    t.string   "stripe_plan_id",         limit: 255
    t.string   "stripe_customer_id",     limit: 255
    t.string   "stripe_subscription_id", limit: 255
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "donations", ["email"], name: "index_donations_on_email", unique: true, using: :btree

  create_table "email_batches", force: :cascade do |t|
    t.integer  "no_emails",       limit: 4
    t.integer  "no_applications", limit: 4
    t.integer  "no_comments",     limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "replies", force: :cascade do |t|
    t.text     "text",          limit: 65535
    t.datetime "received_at"
    t.integer  "comment_id",    limit: 4
    t.integer  "councillor_id", limit: 4
    t.integer  "writeit_id",    limit: 4
  end

  add_index "replies", ["comment_id"], name: "index_replies_on_comment_id", using: :btree
  add_index "replies", ["councillor_id"], name: "index_replies_on_councillor_id", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.text     "details",    limit: 65535
    t.integer  "comment_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stats", force: :cascade do |t|
    t.string  "key",   limit: 25, null: false
    t.integer "value", limit: 4,  null: false
  end

  create_table "suggested_councillors", force: :cascade do |t|
    t.string   "name",                       limit: 255
    t.string   "email",                      limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "councillor_contribution_id", limit: 4
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 128, default: "",    null: false
    t.string   "password_salt",          limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.string   "remember_token",         limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reset_password_sent_at"
    t.boolean  "admin",                              default: false, null: false
    t.string   "api_key",                limit: 255
    t.string   "name",                   limit: 255
    t.string   "organisation",           limit: 255
    t.boolean  "bulk_api",                           default: false, null: false
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.boolean  "api_disabled",                       default: false
  end

  add_index "users", ["api_key"], name: "index_users_on_api_key", using: :btree
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "vanity_conversions", force: :cascade do |t|
    t.integer "vanity_experiment_id", limit: 4
    t.integer "alternative",          limit: 4
    t.integer "conversions",          limit: 4
  end

  add_index "vanity_conversions", ["vanity_experiment_id", "alternative"], name: "by_experiment_id_and_alternative", using: :btree

  create_table "vanity_experiments", force: :cascade do |t|
    t.string   "experiment_id", limit: 255
    t.integer  "outcome",       limit: 4
    t.datetime "created_at"
    t.datetime "completed_at"
  end

  add_index "vanity_experiments", ["experiment_id"], name: "index_vanity_experiments_on_experiment_id", using: :btree

  create_table "vanity_metric_values", force: :cascade do |t|
    t.integer "vanity_metric_id", limit: 4
    t.integer "index",            limit: 4
    t.integer "value",            limit: 4
    t.string  "date",             limit: 255
  end

  add_index "vanity_metric_values", ["vanity_metric_id"], name: "index_vanity_metric_values_on_vanity_metric_id", using: :btree

  create_table "vanity_metrics", force: :cascade do |t|
    t.string   "metric_id",  limit: 255
    t.datetime "updated_at"
  end

  add_index "vanity_metrics", ["metric_id"], name: "index_vanity_metrics_on_metric_id", using: :btree

  create_table "vanity_participants", force: :cascade do |t|
    t.string  "experiment_id", limit: 255
    t.string  "identity",      limit: 255
    t.integer "shown",         limit: 4
    t.integer "seen",          limit: 4
    t.integer "converted",     limit: 4
  end

  add_index "vanity_participants", ["experiment_id", "converted"], name: "by_experiment_id_and_converted", using: :btree
  add_index "vanity_participants", ["experiment_id", "identity"], name: "by_experiment_id_and_identity", using: :btree
  add_index "vanity_participants", ["experiment_id", "seen"], name: "by_experiment_id_and_seen", using: :btree
  add_index "vanity_participants", ["experiment_id", "shown"], name: "by_experiment_id_and_shown", using: :btree
  add_index "vanity_participants", ["experiment_id"], name: "index_vanity_participants_on_experiment_id", using: :btree

  add_foreign_key "applications", "authorities", name: "applications_authority_id_fk"
end
