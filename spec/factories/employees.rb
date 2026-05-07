FactoryBot.define do
  factory :employee do
    association :department, strategy: :create
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    sequence(:email) { |n| "employee#{n}@example.com" }
    department_note { "Notes" }
    designation { "Developer" }
    base_salary { 75_000 }
  end
end
