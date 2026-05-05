class CreatePayrollEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :payroll_entries do |t|
      t.references :employee, null: false, foreign_key: true
      t.integer :period_year, null: false
      t.integer :period_month, null: false
      t.decimal :gross_amount, precision: 14, scale: 2, null: false
      t.decimal :deductions_amount, precision: 14, scale: 2, null: false, default: 0
      t.decimal :net_amount, precision: 14, scale: 2, null: false

      t.timestamps
    end

    add_index :payroll_entries, %i[employee_id period_year period_month], unique: true, name: "idx_payroll_entries_employee_period"
  end
end
