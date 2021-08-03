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

ActiveRecord::Schema.define(version: 2021_08_03_012352) do

  create_table "active_admin_comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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

  create_table "alerts", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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
    t.datetime "last_delivered_at"
    t.boolean "last_delivered_successfully"
    t.string "unsubscribed_by"
    t.index ["email"], name: "index_alerts_on_email"
  end

  create_table "application_redirects", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "application_id", null: false
    t.integer "redirect_application_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_application_redirects_on_application_id"
    t.index ["redirect_application_id"], name: "fk_rails_24f1a5992a"
  end

  create_table "application_versions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "application_id", null: false
    t.bigint "previous_version_id"
    t.boolean "current", null: false
    t.text "address", null: false
    t.text "description", null: false
    t.string "info_url", limit: 1024, null: false
    t.string "comment_url", limit: 1024
    t.date "date_received"
    t.date "on_notice_from"
    t.date "on_notice_to"
    t.timestamp "date_scraped", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.float "lat", limit: 53
    t.float "lng", limit: 53
    t.string "suburb", limit: 50
    t.string "state", limit: 10
    t.string "postcode", limit: 4
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["application_id"], name: "index_application_versions_on_application_id"
    t.index ["date_scraped"], name: "index_application_versions_on_date_scraped"
    t.index ["lat", "lng", "date_scraped"], name: "index_application_versions_on_lat_and_lng_and_date_scraped"
    t.index ["postcode"], name: "index_application_versions_on_postcode"
    t.index ["previous_version_id"], name: "index_application_versions_on_previous_version_id"
    t.index ["state"], name: "index_application_versions_on_state"
    t.index ["suburb"], name: "index_application_versions_on_suburb"
  end

  create_table "applications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "council_reference", limit: 50, null: false
    t.integer "authority_id", null: false
    t.integer "no_alerted"
    t.integer "visible_comments_count", default: 0, null: false
    t.index ["authority_id", "council_reference"], name: "index_applications_on_authority_id_and_council_reference", unique: true
    t.index ["authority_id"], name: "authority_id"
    t.index ["visible_comments_count"], name: "index_applications_on_visible_comments_count"
  end

  create_table "authorities", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "full_name", limit: 200, null: false
    t.string "short_name", limit: 100, null: false
    t.boolean "disabled", null: false
    t.string "state", limit: 20, null: false
    t.string "email"
    t.text "last_scraper_run_log"
    t.string "morph_name"
    t.boolean "write_to_councillors_enabled", default: false, null: false
    t.string "website_url"
    t.integer "population_2017"
    t.string "scraper_authority_label", comment: "For scrapers for multiple authorities filter by this label"
    t.index ["short_name"], name: "short_name_unique", unique: true
  end

  create_table "comments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.text "text", limit: 16777215
    t.string "email"
    t.string "name"
    t.integer "application_id", null: false
    t.string "confirm_id"
    t.boolean "confirmed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "address"
    t.boolean "hidden", default: false, null: false
    t.integer "councillor_id"
    t.datetime "confirmed_at"
    t.integer "writeit_message_id"
    t.datetime "last_delivered_at"
    t.boolean "last_delivered_successfully"
    t.index ["application_id"], name: "index_comments_on_application_id"
    t.index ["confirm_id"], name: "index_comments_on_confirm_id"
    t.index ["confirmed"], name: "index_comments_on_confirmed"
    t.index ["councillor_id"], name: "fk_rails_f9fd210b40"
    t.index ["hidden"], name: "index_comments_on_hidden"
  end

  create_table "contributors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "councillor_contributions", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "contributor_id"
    t.integer "authority_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "source"
    t.boolean "reviewed", default: false, null: false
    t.boolean "accepted", default: false, null: false
    t.index ["authority_id"], name: "fk_rails_b23f89eb2a"
    t.index ["contributor_id"], name: "fk_rails_7fd8de62d1"
  end

  create_table "councillors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name", null: false
    t.string "image_url"
    t.string "party"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", null: false
    t.integer "authority_id", null: false
    t.string "popolo_id", null: false
    t.boolean "current", default: true, null: false
    t.index ["authority_id"], name: "fk_rails_d8c8595037"
  end

  create_table "email_batches", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "no_emails", null: false
    t.integer "no_applications", null: false
    t.integer "no_comments", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "no_replies", null: false
    t.index ["created_at"], name: "index_email_batches_on_created_at"
  end

  create_table "geocode_queries", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "query", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "geocode_results", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "geocoder", null: false
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "geocode_query_id", null: false
    t.string "suburb"
    t.string "state"
    t.string "postcode"
    t.string "full_address"
    t.index ["geocode_query_id"], name: "index_geocode_results_on_geocode_query_id"
  end

  create_table "github_issues", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.integer "authority_id", null: false
    t.string "github_repo", null: false
    t.integer "github_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authority_id"], name: "index_github_issues_on_authority_id"
  end

  create_table "replies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.text "text", limit: 16777215
    t.datetime "received_at"
    t.integer "comment_id", null: false
    t.integer "councillor_id", null: false
    t.integer "writeit_id"
    t.index ["comment_id"], name: "index_replies_on_comment_id"
    t.index ["councillor_id"], name: "index_replies_on_councillor_id"
  end

  create_table "reports", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "details", limit: 16777215
    t.integer "comment_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["comment_id"], name: "fk_rails_bc3addd41c"
  end

  create_table "site_settings", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "settings"
    t.datetime "created_at"
  end

  create_table "stats", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "key", limit: 25, default: "", null: false
    t.integer "value", null: false
  end

  create_table "suggested_councillors", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "councillor_contribution_id", null: false
    t.index ["councillor_contribution_id"], name: "fk_rails_34c0974132"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci ROW_FORMAT=DYNAMIC", force: :cascade do |t|
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
    t.boolean "unlimited_api_usage", default: false, null: false
    t.boolean "api_commercial", default: false, null: false, comment: "api key is being used by a commercial customer"
    t.index ["api_key"], name: "index_users_on_api_key"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "application_redirects", "applications", column: "redirect_application_id"
  add_foreign_key "application_versions", "application_versions", column: "previous_version_id"
  add_foreign_key "application_versions", "applications"
  add_foreign_key "applications", "authorities", name: "applications_authority_id_fk"
  add_foreign_key "comments", "applications"
  add_foreign_key "comments", "councillors"
  add_foreign_key "councillor_contributions", "authorities"
  add_foreign_key "councillor_contributions", "contributors"
  add_foreign_key "councillors", "authorities"
  add_foreign_key "geocode_results", "geocode_queries"
  add_foreign_key "github_issues", "authorities"
  add_foreign_key "replies", "comments"
  add_foreign_key "replies", "councillors"
  add_foreign_key "reports", "comments"
  add_foreign_key "suggested_councillors", "councillor_contributions"
end
