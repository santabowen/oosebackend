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

ActiveRecord::Schema.define(version: 20151204035016) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "activities", force: :cascade do |t|
    t.string   "activity_type"
    t.string   "location"
    t.integer  "group_size"
    t.integer  "member_number"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.string   "comments"
    t.integer  "duration"
    t.string   "hostid"
    t.integer  "user_id"
    t.decimal  "longitude",     precision: 64, scale: 12
    t.decimal  "latitude",      precision: 64, scale: 12
    t.datetime "start_time"
  end

  add_index "activities", ["user_id", "created_at"], name: "index_activities_on_user_id_and_created_at", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "filters", force: :cascade do |t|
    t.string   "filtertype"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "filters", ["user_id"], name: "index_filters_on_user_id", using: :btree

  create_table "memberactivities", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "activity_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "memberactivities", ["activity_id"], name: "index_memberactivities_on_activity_id", using: :btree
  add_index "memberactivities", ["user_id", "activity_id"], name: "index_memberactivities_on_user_id_and_activity_id", unique: true, using: :btree
  add_index "memberactivities", ["user_id"], name: "index_memberactivities_on_user_id", using: :btree

  create_table "ratings", force: :cascade do |t|
    t.integer  "activity_id"
    t.integer  "user_id"
    t.integer  "member_id"
    t.integer  "rating"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "password_digest"
    t.string   "authtoken"
    t.string   "password_salt"
    t.string   "gender"
    t.string   "validation_code"
    t.datetime "validation_time"
    t.string   "avatar"
    t.string   "address"
    t.string   "self_description"
    t.integer  "num_rating"
    t.float    "total_rating"
    t.float    "rating"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

end
