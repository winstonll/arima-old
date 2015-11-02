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

ActiveRecord::Schema.define(version: 20151027182324) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "shared_twitter"
    t.boolean  "shared_facebook"
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["user_id"], name: "index_answers_on_user_id", using: :btree

  create_table "badges", force: true do |t|
    t.integer  "user_id"
    t.integer  "badge_id"
    t.string   "date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "label"
  end

  create_table "friendly_id_slugs", force: true do |t|
    t.string   "slug",                      null: false
    t.integer  "sluggable_id",              null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope"
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "fun_facts", force: true do |t|
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "page_class"
    t.string   "slug"
  end

  create_table "groups_questions", force: true do |t|
    t.integer  "group_id"
    t.integer  "question_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "groups_questions", ["group_id"], name: "index_groups_questions_on_group_id", using: :btree
  add_index "groups_questions", ["question_id"], name: "index_groups_questions_on_question_id", using: :btree

  create_table "locations", force: true do |t|
    t.string   "city"
    t.string   "province"
    t.string   "country"
    t.string   "continent"
    t.string   "lat_lng"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.string   "country_code"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "ip_address"
    t.string   "zip_code"
  end

  add_index "locations", ["city"], name: "index_locations_on_city", using: :btree
  add_index "locations", ["country_code"], name: "index_locations_on_country_code", using: :btree
  add_index "locations", ["user_id"], name: "index_locations_on_user_id", using: :btree

  create_table "opinions", force: true do |t|
    t.integer  "user_id"
    t.integer  "tag_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "question_id"
    t.string   "vote_type"
  end

  create_table "questions", force: true do |t|
    t.string   "label"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value_type"
    t.text     "options_for_collection"
    t.string   "slug"
    t.integer  "user_id"
    t.integer  "group_id"
    t.integer  "votecount",              default: 0
    t.string   "image_link"
    t.boolean  "shared_image"
    t.integer  "tag_count",              default: 0
  end

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

  create_table "submit_questions", force: true do |t|
    t.string   "title",                              null: false
    t.string   "category",                           null: false
    t.string   "answer_type",                        null: false
    t.text     "answers",                            null: false
    t.boolean  "approved",           default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.boolean  "wants_subscription"
    t.text     "created_by"
  end

  create_table "tags", force: true do |t|
    t.string   "label"
    t.integer  "question_id"
    t.integer  "counter"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "x_ratio"
    t.float    "y_ratio"
    t.integer  "reply_id",    default: 0
    t.integer  "level",       default: 0
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",     null: false
    t.string   "encrypted_password",     default: "",     null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,      null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "measurement_unit"
    t.string   "currency_unit"
    t.integer  "points",                 default: 0
    t.boolean  "fake",                   default: false
    t.date     "daily_score_award_date"
    t.string   "gender"
    t.string   "username"
    t.date     "dob"
    t.string   "password_reset_token"
    t.string   "referral_code"
    t.datetime "last_emailed_at"
    t.integer  "birthyear"
    t.string   "ip_address"
    t.string   "share_modal_state",      default: "show"
    t.integer  "rank"
  end

  add_index "users", ["dob"], name: "index_users_on_dob", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "votes", force: true do |t|
    t.integer  "question_id"
    t.integer  "user_id"
    t.string   "vote_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
