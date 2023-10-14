# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_10_14_171414) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.string "message_id", null: false
    t.string "message_checksum", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "active_admin_comments", id: :serial, force: :cascade do |t|
    t.string "resource_id", default: "", null: false
    t.string "resource_type", default: "", null: false
    t.integer "author_id"
    t.string "author_type"
    t.text "body"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "namespace"
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alerts", id: :serial, force: :cascade do |t|
    t.string "address", limit: 120, default: "", null: false
    t.datetime "last_sent", precision: nil
    t.float "lat", null: false
    t.float "lng", null: false
    t.string "confirm_id", limit: 20
    t.integer "radius_meters", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.boolean "unsubscribed", default: false, null: false
    t.datetime "last_processed", precision: nil
    t.datetime "unsubscribed_at", precision: nil
    t.datetime "last_delivered_at", precision: nil
    t.boolean "last_delivered_successfully"
    t.string "unsubscribed_by"
    t.integer "user_id", null: false
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.index ["lonlat"], name: "index_alerts_on_lonlat", using: :gist
    t.index ["user_id"], name: "fk_rails_d4053234e7"
  end

  create_table "api_keys", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "value", null: false
    t.boolean "bulk", default: false, null: false
    t.boolean "disabled", default: false, null: false
    t.boolean "commercial", default: false, null: false, comment: "api key is being used by a commercial customer"
    t.integer "daily_limit", comment: "override default daily API request limit"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_api_keys_on_user_id"
    t.index ["value"], name: "index_api_keys_on_value"
  end

  create_table "application_redirects", id: :serial, force: :cascade do |t|
    t.integer "application_id", null: false
    t.integer "redirect_application_id", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["application_id"], name: "index_application_redirects_on_application_id"
    t.index ["redirect_application_id"], name: "fk_rails_24f1a5992a"
  end

  create_table "application_versions", force: :cascade do |t|
    t.integer "application_id", null: false
    t.bigint "previous_version_id"
    t.boolean "current", null: false
    t.text "address", null: false
    t.text "description", null: false
    t.string "info_url", limit: 1024, default: "", null: false
    t.string "comment_url", limit: 1024
    t.date "date_received"
    t.date "on_notice_from"
    t.date "on_notice_to"
    t.datetime "date_scraped", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.float "lat"
    t.float "lng"
    t.string "suburb", limit: 50
    t.string "state", limit: 10
    t.string "postcode", limit: 4
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "comment_email"
    t.string "comment_authority"
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.index ["application_id"], name: "index_application_versions_on_application_id"
    t.index ["date_scraped"], name: "index_application_versions_on_date_scraped"
    t.index ["lat", "lng", "date_scraped"], name: "index_application_versions_on_lat_and_lng_and_date_scraped"
    t.index ["postcode"], name: "index_application_versions_on_postcode"
    t.index ["previous_version_id"], name: "index_application_versions_on_previous_version_id"
    t.index ["state"], name: "index_application_versions_on_state"
    t.index ["suburb"], name: "index_application_versions_on_suburb"
  end

  create_table "applications", id: :serial, force: :cascade do |t|
    t.string "council_reference", limit: 50, default: "", null: false
    t.integer "authority_id", null: false
    t.integer "no_alerted"
    t.integer "visible_comments_count", default: 0, null: false
    t.datetime "first_date_scraped", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.text "address"
    t.text "description"
    t.string "info_url", limit: 1024
    t.date "date_received"
    t.date "on_notice_from"
    t.date "on_notice_to"
    t.datetime "date_scraped", precision: nil, default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.float "lat"
    t.float "lng"
    t.string "suburb", limit: 50
    t.string "state", limit: 10
    t.string "postcode", limit: 4
    t.string "comment_email"
    t.string "comment_authority"
    t.geography "lonlat", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.index ["authority_id", "council_reference"], name: "index_applications_on_authority_id_and_council_reference", unique: true
    t.index ["authority_id", "date_scraped"], name: "index_applications_on_authority_id_and_date_scraped"
    t.index ["authority_id", "first_date_scraped"], name: "index_applications_on_authority_id_and_first_date_scraped"
    t.index ["date_scraped", "lat", "lng"], name: "index_applications_on_date_scraped_and_lat_and_lng"
    t.index ["first_date_scraped", "lat", "lng"], name: "index_applications_on_first_date_scraped_and_lat_and_lng"
    t.index ["lat", "lng", "date_scraped"], name: "index_applications_on_lat_and_lng_and_date_scraped"
    t.index ["lonlat"], name: "index_applications_on_lonlat", using: :gist
    t.index ["postcode"], name: "index_applications_on_postcode"
    t.index ["state"], name: "index_applications_on_state"
    t.index ["suburb"], name: "index_applications_on_suburb"
    t.index ["visible_comments_count"], name: "index_applications_on_visible_comments_count"
  end

  create_table "authorities", id: :serial, force: :cascade do |t|
    t.string "full_name", limit: 200, default: "", null: false
    t.string "short_name", limit: 100, default: "", null: false
    t.boolean "disabled", null: false
    t.string "state", limit: 20, null: false
    t.string "email"
    t.text "last_scraper_run_log"
    t.string "morph_name"
    t.string "website_url"
    t.string "scraper_authority_label", comment: "For scrapers for multiple authorities filter by this label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "wikidata_id"
    t.integer "population_2021"
    t.string "asgs_2021"
    t.geography "boundary", limit: {:srid=>4326, :type=>"multi_polygon", :geographic=>true}
    t.index ["short_name"], name: "short_name_unique", unique: true
  end

  create_table "comments", id: :serial, force: :cascade do |t|
    t.text "text"
    t.string "name"
    t.integer "application_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.string "address"
    t.boolean "hidden", default: false, null: false
    t.datetime "last_delivered_at", precision: nil
    t.boolean "last_delivered_successfully"
    t.integer "user_id"
    t.boolean "previewed", null: false
    t.datetime "published_at"
    t.index ["application_id"], name: "index_comments_on_application_id"
    t.index ["hidden"], name: "index_comments_on_hidden"
    t.index ["previewed"], name: "index_comments_on_previewed"
    t.index ["published_at", "previewed", "hidden"], name: "index_comments_on_published_at_and_previewed_and_hidden"
    t.index ["user_id"], name: "fk_rails_03de2dc08c"
  end

  create_table "contact_messages", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "email", null: false
    t.string "reason", null: false
    t.text "details", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_api_usages", force: :cascade do |t|
    t.integer "api_key_id", null: false
    t.date "date", null: false
    t.integer "count", default: 0, null: false
    t.index ["api_key_id", "date"], name: "index_daily_api_usages_on_api_key_id_and_date", unique: true
    t.index ["api_key_id"], name: "index_daily_api_usages_on_api_key_id"
    t.index ["date"], name: "index_daily_api_usages_on_date"
  end

  create_table "email_batches", id: :serial, force: :cascade do |t|
    t.integer "no_emails", null: false
    t.integer "no_applications", null: false
    t.integer "no_comments", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["created_at"], name: "index_email_batches_on_created_at"
  end

  create_table "geocode_queries", force: :cascade do |t|
    t.string "query", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "geocode_results", force: :cascade do |t|
    t.string "geocoder", default: "", null: false
    t.float "lat"
    t.float "lng"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "geocode_query_id", null: false
    t.string "suburb"
    t.string "state"
    t.string "postcode"
    t.string "full_address"
    t.index ["geocode_query_id"], name: "index_geocode_results_on_geocode_query_id"
  end

  create_table "github_issues", force: :cascade do |t|
    t.integer "authority_id", null: false
    t.string "github_repo", null: false
    t.integer "github_number", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["authority_id"], name: "index_github_issues_on_authority_id"
  end

  create_table "reports", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.text "details"
    t.integer "comment_id", null: false
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "user_id"
    t.index ["comment_id"], name: "fk_rails_bc3addd41c"
  end

  create_table "stats", id: :serial, force: :cascade do |t|
    t.string "key", limit: 25, default: "", null: false
    t.integer "value", null: false
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "password_salt", default: "", null: false
    t.string "reset_password_token"
    t.string "remember_token"
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.boolean "admin", default: false, null: false
    t.string "name"
    t.string "organisation"
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.boolean "from_alert_or_comment", default: false, null: false, comment: "whether this user was created from an alert or comment rather than through the normal devise registration process"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.datetime "activated_at"
    t.boolean "tailwind_theme", default: false, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerts", "users"
  add_foreign_key "api_keys", "users"
  add_foreign_key "application_redirects", "applications", column: "redirect_application_id"
  add_foreign_key "application_versions", "application_versions", column: "previous_version_id"
  add_foreign_key "application_versions", "applications"
  add_foreign_key "applications", "authorities", name: "applications_authority_id_fk"
  add_foreign_key "comments", "applications"
  add_foreign_key "comments", "users"
  add_foreign_key "daily_api_usages", "api_keys"
  add_foreign_key "geocode_results", "geocode_queries"
  add_foreign_key "github_issues", "authorities"
  add_foreign_key "reports", "comments"
end
