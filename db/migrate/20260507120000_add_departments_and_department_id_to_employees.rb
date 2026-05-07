class AddDepartmentsAndDepartmentIdToEmployees < ActiveRecord::Migration[8.1]
  class MigrationDepartment < ApplicationRecord
    self.table_name = "departments"
  end

  class MigrationEmployee < ApplicationRecord
    self.table_name = "employees"
  end

  def up
    rename_column :employees, :department, :department_note

    create_table :departments do |t|
      t.string :name, null: false
      t.timestamps
    end

    add_index :departments, "LOWER(name)", unique: true, name: "index_departments_on_lower_name"

    add_reference :employees, :department, foreign_key: true

    general = MigrationDepartment.create!(name: "General")
    eng = MigrationDepartment.create!(name: "Engineering")
    res = MigrationDepartment.create!(name: "Research")

    MigrationEmployee.reset_column_information
    MigrationEmployee.find_each do |emp|
      note = emp.read_attribute(:department_note).to_s.downcase
      dept_id = if note.include?("research")
        res.id
      elsif note.include?("engine") || note.include?("hr") || note.include?("human")
        eng.id
      else
        general.id
      end
      emp.update_column(:department_id, dept_id)
    end

    MigrationEmployee.where(department_id: nil).update_all(department_id: general.id)
    change_column_null :employees, :department_id, false
  end

  def down
    remove_reference :employees, :department, foreign_key: true
    drop_table :departments
    rename_column :employees, :department_note, :department
  end
end
