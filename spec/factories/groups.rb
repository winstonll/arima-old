# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :group do
    sequence(:label) { |i| "Group #{i}" }
  end
end
