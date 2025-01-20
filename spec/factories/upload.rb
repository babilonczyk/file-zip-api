FactoryBot.define do
  factory :upload do
    sequence(:name) { |i| "file name#{i}" }
    url { 'https://www.example.com' }

    user
  end
end
