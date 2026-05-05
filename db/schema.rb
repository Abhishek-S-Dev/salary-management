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

ActiveRecord::Schema[8.1].define(version: 2026_05_05_120645) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "employees", force: :cascade do |t|
    t.decimal "base_salary", precision: 14, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "department"
    t.string "designation"
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_employees_on_lower_email", unique: true
  end

  create_table "payroll_entries", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "deductions_amount", precision: 14, scale: 2, default: "0.0", null: false
    t.bigint "employee_id", null: false
    t.decimal "gross_amount", precision: 14, scale: 2, null: false
    t.decimal "net_amount", precision: 14, scale: 2, null: false
    t.integer "period_month", null: false
    t.integer "period_year", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "period_year", "period_month"], name: "idx_payroll_entries_employee_period", unique: true
    t.index ["employee_id"], name: "index_payroll_entries_on_employee_id"
  end

  add_foreign_key "payroll_entries", "employees"
end
