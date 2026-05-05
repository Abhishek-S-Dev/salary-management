FactoryBot.define do
  factory :payroll_entry do
    employee
    period_year { 2026 }
    sequence(:period_month) { |n| (n % 12) + 1 }
    gross_amount { 10_000 }
    deductions_amount { 1500 }
    net_amount { 8500 }
  end
end
