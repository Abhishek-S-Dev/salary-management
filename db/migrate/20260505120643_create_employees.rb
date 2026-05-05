class CreateEmployees < ActiveRecord::Migration[8.1]
  def change
    create_table :employees do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :department
      t.string :designation
      t.decimal :base_salary, precision: 14, scale: 2, null: false

      t.timestamps
    end
    add_index :employees, "LOWER(email)", unique: true, name: "index_employees_on_lower_email"
  end
end
