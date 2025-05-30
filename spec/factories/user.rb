FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password' }
    password_confirmation { 'password' }
    sequence(:username) { |n| "user#{n}" }


    after(:create) do |user|
      user.create_cart!
    end
  end
end
