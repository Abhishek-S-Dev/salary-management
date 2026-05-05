# Sample data for local demos (idempotent).

ada = Employee.find_or_initialize_by(email: "ada.lovelace@example.com")
ada.assign_attributes(
  first_name: "Ada",
  last_name: "Lovelace",
  department: "Engineering",
  designation: "Lead",
  base_salary: 120_000
)
ada.save!

alan = Employee.find_or_initialize_by(email: "alan.turing@example.com")
alan.assign_attributes(
  first_name: "Alan",
  last_name: "Turing",
  department: "Research",
  designation: "Scientist",
  base_salary: 95_000
)
alan.save!

PayrollEntry.find_or_create_by!(employee: ada, period_year: 2026, period_month: 4) do |row|
  row.gross_amount = 10_000
  row.deductions_amount = 2200
end

PayrollEntry.find_or_create_by!(employee: ada, period_year: 2026, period_month: 5) do |row|
  row.gross_amount = 10_200
  row.deductions_amount = 2300
end

PayrollEntry.find_or_create_by!(employee: alan, period_year: 2026, period_month: 5) do |row|
  row.gross_amount = 8200
  row.deductions_amount = 1100
end
