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

ActiveRecord::Schema.define(version: 20171129011045) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "addresses", force: :cascade do |t|
    t.string "street_address"
    t.string "post_code"
    t.string "city"
    t.string "country", default: "Sverige", null: false
    t.bigint "region_id"
    t.string "addressable_type"
    t.bigint "addressable_id"
    t.bigint "kommun_id"
    t.float "latitude"
    t.float "longitude"
    t.string "visibility", default: "street_address"
    t.boolean "mail", default: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable_type_and_addressable_id"
    t.index ["kommun_id"], name: "index_addresses_on_kommun_id"
    t.index ["latitude", "longitude"], name: "index_addresses_on_latitude_and_longitude"
    t.index ["region_id"], name: "index_addresses_on_region_id"
  end

  create_table "business_categories", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "business_categories_membership_applications", force: :cascade do |t|
    t.bigint "membership_application_id"
    t.bigint "business_category_id"
    t.index ["business_category_id"], name: "index_on_categories"
    t.index ["membership_application_id"], name: "index_on_applications"
  end

  create_table "ckeditor_assets", force: :cascade do |t|
    t.string "data_file_name", null: false
    t.string "data_content_type"
    t.integer "data_file_size"
    t.string "data_fingerprint"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.index ["company_id"], name: "index_ckeditor_assets_on_company_id"
    t.index ["type"], name: "index_ckeditor_assets_on_type"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "company_number"
    t.string "phone_number"
    t.string "email"
    t.string "website"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "description"
    t.string "dinkurs_key"
    t.index ["company_number"], name: "index_companies_on_company_number", unique: true
  end

  create_table "dinkurs_events", force: :cascade, comment: "Information tracked by the DinKurs.se system about an Event" do |t|
    t.string "dinkurs_id", comment: "unique identifier for the event in the DinKurs system"
    t.string "name", comment: "text name of the event"
    t.string "place_geometry_location", comment: "location geocoordinates"
    t.string "host"
    t.float "fee", comment: "cost of the event (for a ticket)"
    t.float "fee_tax", comment: "tax that is in addition to the cost"
    t.datetime "pub", comment: "date the event is published?"
    t.datetime "apply", comment: "TODO date ? "
    t.datetime "start", comment: "start date and time for the event"
    t.datetime "stop", comment: "stop date and time for the event"
    t.decimal "participant_number", comment: "max. number of participants allowed for the event"
    t.decimal "participant_reserve", comment: "number of participants waiting for a spot to be available for the event"
    t.decimal "participants", comment: "number of participants signed up for the event"
    t.string "occasions"
    t.string "group"
    t.string "position"
    t.string "instructor_1", comment: "name of instructor 1 for the event"
    t.string "instructor_2", comment: "name of instructor 2 for the event"
    t.string "instructor_3", comment: "name of instructor 3 for the event"
    t.string "infotext", comment: "More text details about the event"
    t.string "commenttext"
    t.string "ticket_info"
    t.string "key", comment: "unique identifier for DinKurs used to construct the event_url_key"
    t.string "url_id"
    t.string "url_key"
    t.string "completion_text"
    t.string "aftertext"
    t.string "dates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.string "place"
    t.index ["company_id"], name: "index_dinkurs_events_on_company_id"
  end

  create_table "kommuns", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "member_app_waiting_reasons", force: :cascade, comment: "reasons why SHF is waiting for more info from applicant. Add more columns when more locales needed." do |t|
    t.string "name_sv", comment: "name of the reason in svenska/Swedish"
    t.string "description_sv", comment: "description for the reason in svenska/Swedish"
    t.string "name_en", comment: "name of the reason in engelsk/English"
    t.string "description_en", comment: "description for the reason in engelsk/English"
    t.boolean "is_custom", default: false, null: false, comment: "was this entered as a new 'custom' reason?"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "member_pages", force: :cascade do |t|
    t.string "filename", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "membership_applications", force: :cascade do |t|
    t.string "company_number"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "contact_email"
    t.bigint "company_id"
    t.string "state", default: "new"
    t.integer "member_app_waiting_reasons_id"
    t.string "custom_reason_text"
    t.index ["company_id"], name: "index_membership_applications_on_company_id"
    t.index ["member_app_waiting_reasons_id"], name: "index_membership_applications_on_member_app_waiting_reasons_id"
    t.index ["user_id"], name: "index_membership_applications_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "company_id"
    t.string "payment_type"
    t.string "status"
    t.string "hips_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "start_date"
    t.date "expire_date"
    t.text "notes"
    t.index ["company_id"], name: "index_payments_on_company_id"
    t.index ["user_id"], name: "index_payments_on_user_id"
  end

  create_table "regions", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "shf_documents", force: :cascade do |t|
    t.bigint "uploader_id", null: false
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "actual_file_file_name"
    t.string "actual_file_content_type"
    t.integer "actual_file_file_size"
    t.datetime "actual_file_updated_at"
    t.index ["uploader_id"], name: "index_shf_documents_on_uploader_id"
  end

  create_table "uploaded_files", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "actual_file_file_name"
    t.string "actual_file_content_type"
    t.integer "actual_file_file_size"
    t.datetime "actual_file_updated_at"
    t.bigint "membership_application_id"
    t.index ["membership_application_id"], name: "index_uploaded_files_on_membership_application_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "first_name"
    t.string "last_name"
    t.string "membership_number"
    t.boolean "member", default: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["membership_number"], name: "index_users_on_membership_number", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "addresses", "kommuns"
  add_foreign_key "addresses", "regions"
  add_foreign_key "ckeditor_assets", "companies"
  add_foreign_key "dinkurs_events", "companies"
  add_foreign_key "membership_applications", "member_app_waiting_reasons", column: "member_app_waiting_reasons_id"
  add_foreign_key "membership_applications", "users"
  add_foreign_key "payments", "companies"
  add_foreign_key "payments", "users"
  add_foreign_key "shf_documents", "users", column: "uploader_id"
  add_foreign_key "uploaded_files", "membership_applications"
end
