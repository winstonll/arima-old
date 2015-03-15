# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    sequence(:email) { |i| "Email #{i}" }
    sequence(:first_name) { |i| "John #{i}" }
    last_name "Doe"
    sequence(:gender) { |i| i.even? ? 'M' : 'F' }
    sequence(:dob) { |i| (i % 30 + 15).years.ago }
    password "arima123!"

    after(:create) do |user|
      create_list(:location, 1, user: user)
      create_list(:answer, 1, user: user)
    end
  end
end
