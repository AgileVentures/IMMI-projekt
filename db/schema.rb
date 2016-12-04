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

ActiveRecord::Schema.define(version: 20161202101242) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "business_categories", force: :cascade do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "business_categories_companies", force: :cascade do |t|
    t.integer "company_id"
    t.integer "business_category_id"
    t.index ["business_category_id"], name: "index_on_co_categories", using: :btree
    t.index ["company_id"], name: "index_on_companies", using: :btree
  end

  create_table "business_categories_membership_applications", force: :cascade do |t|
    t.integer "membership_application_id"
    t.integer "business_category_id"
    t.index ["business_category_id"], name: "index_on_categories", using: :btree
    t.index ["membership_application_id"], name: "index_on_applications", using: :btree
  end

  create_table "companies", force: :cascade do |t|
    t.string   "name"
    t.string   "company_number"
    t.string   "phone_number"
    t.string   "email"
    t.string   "street"
    t.string   "post_code"
    t.string   "city"
    t.string   "region"
    t.string   "website"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "membership_applications", force: :cascade do |t|
    t.string   "company_number"
    t.string   "phone_number"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "user_id"
    t.string   "status",            default: "Pending"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "contact_email"
    t.integer  "company_id"
    t.string   "membership_number"
    t.index ["company_id"], name: "index_membership_applications_on_company_id", using: :btree
    t.index ["user_id"], name: "index_membership_applications_on_user_id", using: :btree
  end

  create_table "uploaded_files", force: :cascade do |t|
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "actual_file_file_name"
    t.string   "actual_file_content_type"
    t.integer  "actual_file_file_size"
    t.datetime "actual_file_updated_at"
    t.integer  "membership_application_id"
    t.index ["membership_application_id"], name: "index_uploaded_files_on_membership_application_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "admin",                  default: false
    t.boolean  "is_member",              default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  add_foreign_key "membership_applications", "users"
  add_foreign_key "uploaded_files", "membership_applications"
end
