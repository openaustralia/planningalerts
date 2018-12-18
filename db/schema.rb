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

ActiveRecord::Schema.define(version: 2018_12_06_032522) do

  create_table "active_admin_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "resource_id", null: false
    t.string "resource_type", null: false
    t.integer "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "namespace"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id"
  end

  create_table "alert_subscribers", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_alert_subscribers_on_email", unique: true
  end

  create_table "alerts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", limit: 120, null: false
    t.string "address", limit: 120, null: false
    t.datetime "last_sent"
    t.float "lat", limit: 53, null: false
    t.float "lng", limit: 53, null: false
    t.string "confirm_id", limit: 20
    t.boolean "confirmed", default: false, null: false
    t.integer "radius_meters", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "unsubscribed", default: false, null: false
    t.datetime "last_processed"
    t.datetime "unsubscribed_at"
    t.integer "alert_subscriber_id"
    t.index ["alert_subscriber_id"], name: "index_alerts_on_alert_subscriber_id"
    t.index ["email"], name: "index_alerts_on_email"
  end

  create_table "api_statistics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "ip_address"
    t.datetime "query_time"
    t.text "query"
    t.text "user_agent"
    t.integer "user_id"
    t.index ["query_time"], name: "index_api_statistics_on_query_time"
    t.index ["user_id"], name: "index_api_statistics_on_user_id"
  end

  create_table "application_redirects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "application_id"
    t.integer "redirect_application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_application_redirects_on_application_id"
  end

  create_table "applications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "council_reference", limit: 50, null: false
    t.text "address", null: false
    t.text "description"
    t.string "info_url", limit: 1024
    t.string "comment_url", limit: 1024
    t.integer "authority_id", null: false
    t.float "lat", limit: 53
    t.float "lng", limit: 53
    t.timestamp "date_scraped", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.date "date_received"
    t.string "suburb", limit: 50
    t.string "state", limit: 10
    t.string "postcode", limit: 4
    t.date "on_notice_from"
    t.date "on_notice_to"
    t.integer "no_alerted"
    t.index ["authority_id", "date_scraped"], name: "index_applications_on_authority_id_and_date_scraped"
    t.index ["authority_id"], name: "authority_id"
    t.index ["date_scraped"], name: "index_applications_on_date_scraped"
    t.index ["lat", "lng", "date_scraped"], name: "index_applications_on_lat_and_lng_and_date_scraped"
    t.index ["postcode"], name: "index_applications_on_postcode"
    t.index ["state"], name: "index_applications_on_state"
    t.index ["suburb"], name: "index_applications_on_suburb"
  end

  create_table "authorities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "full_name", limit: 200, null: false
    t.string "short_name", limit: 100, null: false
    t.boolean "disabled"
    t.string "state", limit: 20
    t.string "email"
    t.text "last_scraper_run_log"
    t.string "morph_name"
    t.boolean "write_to_councillors_enabled", default: false, null: false
    t.string "website_url"
    t.integer "population_2017"
    t.index ["short_name"], name: "short_name_unique", unique: true
  end

  create_table "comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "text", limit: 16777215
    t.string "email"
    t.string "name"
    t.integer "application_id"
    t.string "confirm_id"
    t.boolean "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "address"
    t.boolean "hidden", default: false, null: false
    t.integer "councillor_id"
    t.datetime "confirmed_at"
    t.integer "writeit_message_id"
    t.index ["application_id"], name: "index_comments_on_application_id"
    t.index ["confirm_id"], name: "index_comments_on_confirm_id"
    t.index ["confirmed"], name: "index_comments_on_confirmed"
    t.index ["hidden"], name: "index_comments_on_hidden"
  end

  create_table "contributors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "councillor_contributions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "contributor_id"
    t.integer "authority_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "source"
    t.boolean "reviewed", default: false
    t.boolean "accepted", default: false
  end

  create_table "councillors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "image_url"
    t.string "party"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "email"
    t.integer "authority_id"
    t.string "popolo_id"
    t.boolean "current", default: true, null: false
  end

  create_table "delayed_jobs", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "donations", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "email", null: false
    t.string "stripe_plan_id"
    t.string "stripe_customer_id"
    t.string "stripe_subscription_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_donations_on_email", unique: true
  end

  create_table "email_batches", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "no_emails"
    t.integer "no_applications"
    t.integer "no_comments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "replies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.text "text", limit: 16777215
    t.datetime "received_at"
    t.integer "comment_id"
    t.integer "councillor_id"
    t.integer "writeit_id"
    t.index ["comment_id"], name: "index_replies_on_comment_id"
    t.index ["councillor_id"], name: "index_replies_on_councillor_id"
  end

  create_table "reports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "details"
    t.integer "comment_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "stats", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "key", limit: 25, null: false
    t.integer "value", null: false
  end

  create_table "suggested_councillors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "councillor_contribution_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "password_salt", default: "", null: false
    t.string "reset_password_token"
    t.string "remember_token"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "reset_password_sent_at"
    t.boolean "admin", default: false, null: false
    t.string "api_key"
    t.string "name"
    t.string "organisation"
    t.boolean "bulk_api", default: false, null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.boolean "api_disabled", default: false
    t.index ["api_key"], name: "index_users_on_api_key"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vanity_conversions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "vanity_experiment_id"
    t.integer "alternative"
    t.integer "conversions"
    t.index ["vanity_experiment_id", "alternative"], name: "by_experiment_id_and_alternative"
  end

  create_table "vanity_experiments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "experiment_id"
    t.integer "outcome"
    t.datetime "created_at"
    t.datetime "completed_at"
    t.index ["experiment_id"], name: "index_vanity_experiments_on_experiment_id"
  end

  create_table "vanity_metric_values", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.integer "vanity_metric_id"
    t.integer "index"
    t.integer "value"
    t.string "date"
    t.index ["vanity_metric_id"], name: "index_vanity_metric_values_on_vanity_metric_id"
  end

  create_table "vanity_metrics", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "metric_id"
    t.datetime "updated_at"
    t.index ["metric_id"], name: "index_vanity_metrics_on_metric_id"
  end

  create_table "vanity_participants", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci", force: :cascade do |t|
    t.string "experiment_id"
    t.string "identity"
    t.integer "shown"
    t.integer "seen"
    t.integer "converted"
    t.index ["experiment_id", "converted"], name: "by_experiment_id_and_converted"
    t.index ["experiment_id", "identity"], name: "by_experiment_id_and_identity"
    t.index ["experiment_id", "seen"], name: "by_experiment_id_and_seen"
    t.index ["experiment_id", "shown"], name: "by_experiment_id_and_shown"
    t.index ["experiment_id"], name: "index_vanity_participants_on_experiment_id"
  end

  add_foreign_key "applications", "authorities", name: "applications_authority_id_fk"
end
