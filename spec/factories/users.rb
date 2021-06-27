FactoryBot.define do
  factory :user do
    name { Faker::Name.first_name }
  end
end
