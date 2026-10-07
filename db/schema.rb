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

ActiveRecord::Schema[8.1].define(version: 2026_10_07_070238) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "answers", force: :cascade do |t|
    t.bigint "diagnosis_id", null: false
    t.bigint "question_id", null: false
    t.bigint "choice_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["choice_id"], name: "index_answers_on_choice_id"
    t.index ["diagnosis_id", "question_id"], name: "index_answers_on_diagnosis_id_and_question_id", unique: true
    t.index ["diagnosis_id"], name: "index_answers_on_diagnosis_id"
    t.index ["question_id"], name: "index_answers_on_question_id"
  end

  create_table "choice_scores", force: :cascade do |t|
    t.bigint "choice_id", null: false
    t.bigint "diagnosis_axis_id", null: false
    t.integer "score", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["choice_id", "diagnosis_axis_id"], name: "index_choice_scores_on_choice_id_and_diagnosis_axis_id", unique: true
    t.index ["choice_id"], name: "index_choice_scores_on_choice_id"
    t.index ["diagnosis_axis_id"], name: "index_choice_scores_on_diagnosis_axis_id"
  end

  create_table "choices", force: :cascade do |t|
    t.bigint "question_id", null: false
    t.string "content", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id", "position"], name: "index_choices_on_question_id_and_position", unique: true
    t.index ["question_id"], name: "index_choices_on_question_id"
  end

  create_table "diagnoses", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_diagnoses_on_user_id"
  end

  create_table "diagnosis_axes", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_diagnosis_axes_on_key", unique: true
    t.index ["position"], name: "index_diagnosis_axes_on_position", unique: true
  end

  create_table "diagnosis_scores", force: :cascade do |t|
    t.bigint "diagnosis_id", null: false
    t.bigint "diagnosis_axis_id", null: false
    t.integer "raw_score", null: false
    t.integer "score", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnosis_axis_id"], name: "index_diagnosis_scores_on_diagnosis_axis_id"
    t.index ["diagnosis_id", "diagnosis_axis_id"], name: "index_diagnosis_scores_on_diagnosis_id_and_diagnosis_axis_id", unique: true
    t.index ["diagnosis_id"], name: "index_diagnosis_scores_on_diagnosis_id"
  end

  create_table "questions", force: :cascade do |t|
    t.bigint "diagnosis_axis_id", null: false
    t.text "content", null: false
    t.text "other_content"
    t.integer "position", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diagnosis_axis_id"], name: "index_questions_on_diagnosis_axis_id"
    t.index ["position"], name: "index_questions_on_position", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "answers", "choices"
  add_foreign_key "answers", "diagnoses"
  add_foreign_key "answers", "questions"
  add_foreign_key "choice_scores", "choices"
  add_foreign_key "choice_scores", "diagnosis_axes"
  add_foreign_key "choices", "questions"
  add_foreign_key "diagnoses", "users"
  add_foreign_key "diagnosis_scores", "diagnoses"
  add_foreign_key "diagnosis_scores", "diagnosis_axes"
  add_foreign_key "questions", "diagnosis_axes"
end
