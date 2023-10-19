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

ActiveRecord::Schema[7.0].define(version: 20_231_011_202_038) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "course_id", null: false
    t.string "title", null: false
    t.string "identifier", null: false
    t.jsonb "options", default: {}, null: false
    t.integer "submissions_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_assignments_on_course_id"
    t.index ["identifier"], name: "index_assignments_on_identifier", unique: true
  end

  create_table "courses", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id"
    t.string "title", null: false
    t.string "semester", null: false
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_courses_on_user_id"
  end

  create_table "submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assignment_id"
    t.string "author", null: false
    t.string "type", null: false
    t.string "status", default: "created", null: false
    t.jsonb "data", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_submissions_on_assignment_id"
  end

  create_table "telegram_forms", force: :cascade do |t|
    t.uuid "course_id"
    t.uuid "assignment_id"
    t.uuid "submission_id"
    t.string "chat_identifier"
    t.string "author"
    t.string "stage", default: "initial", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_telegram_forms_on_assignment_id"
    t.index ["chat_identifier"], name: "index_telegram_forms_on_chat_identifier"
    t.index ["course_id"], name: "index_telegram_forms_on_course_id"
    t.index ["submission_id"], name: "index_telegram_forms_on_submission_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "assignments", "courses"
  add_foreign_key "courses", "users"
  add_foreign_key "submissions", "assignments"
  add_foreign_key "telegram_forms", "assignments"
  add_foreign_key "telegram_forms", "courses"
  add_foreign_key "telegram_forms", "submissions"
end
