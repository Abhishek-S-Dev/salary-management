ActiveRecord::Schema[8.1].define(version: 2026_05_05_120645) do
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
