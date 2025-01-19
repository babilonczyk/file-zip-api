FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@test.com" }
    password { 'dummy_password' }
  end
end
