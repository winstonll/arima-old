# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :submit_question do
    title "MyText"
    category "MyString"
    answer_type "MyString"
    answers "MyString"
    approved false
  end
end
