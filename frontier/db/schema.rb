# frozen_string_literal: true

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

ActiveRecord::Schema[7.1].define(version: 20_231_028_164_424) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "plpgsql"

  create_table "assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "course_id", null: false
    t.citext "title", null: false
    t.jsonb "options", default: {}, null: false
    t.integer "submissions_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index %w[course_id title], name: "index_assignments_on_course_id_and_title", unique: true
    t.index ["course_id"], name: "index_assignments_on_course_id"
  end

  create_table "courses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.citext "title", null: false
    t.citext "group", null: false
    t.string "semester", null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["title"], name: "index_courses_on_title", unique: true
    t.index ["user_id"], name: "index_courses_on_user_id"
  end

  create_table "submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assignment_id"
    t.string "author_name", null: false
    t.string "author_group", null: false
    t.string "type", null: false
    t.string "status", default: "created", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_submissions_on_assignment_id"
  end

  create_table "telegram_chats", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "external_identifier", null: false
    t.string "username", null: false
    t.string "name"
    t.string "group"
    t.uuid "last_submitted_course_id"
    t.string "status", default: "created", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_identifier"], name: "index_telegram_chats_on_external_identifier", unique: true
    t.index ["last_submitted_course_id"], name: "index_telegram_chats_on_last_submitted_course_id"
  end

  create_table "telegram_forms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "course_id"
    t.uuid "assignment_id"
    t.uuid "submission_id"
    t.uuid "telegram_chat_id", null: false
    t.string "stage", default: "initial", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_telegram_forms_on_assignment_id"
    t.index ["course_id"], name: "index_telegram_forms_on_course_id"
    t.index ["submission_id"], name: "index_telegram_forms_on_submission_id"
    t.index ["telegram_chat_id"], name: "index_telegram_forms_on_telegram_chat_id"
  end

  create_table "uploads", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "uploadable_type", null: false
    t.uuid "uploadable_id", null: false
    t.string "filename", null: false
    t.jsonb "metadata", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index %w[uploadable_type uploadable_id], name: "index_uploads_on_uploadable"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "assignments", "courses"
  add_foreign_key "courses", "users"
  add_foreign_key "submissions", "assignments"
  add_foreign_key "telegram_chats", "courses", column: "last_submitted_course_id"
  add_foreign_key "telegram_forms", "assignments"
  add_foreign_key "telegram_forms", "courses"
  add_foreign_key "telegram_forms", "submissions"
  add_foreign_key "telegram_forms", "telegram_chats"
end
