# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :question do
    sequence(:label) { |i| "Question #{i}" }
    value_type "text"

    factory :question_collection do
      value_type "collection"
      options_for_collection "1, 2, 3"
    end
  end
end
