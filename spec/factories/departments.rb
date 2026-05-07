FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Division #{n}" }
  end
end
