# encoding: utf-8

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# DO NOT REMOVE EXISTING ENTRY UNLESS YOU ARE WILLING TO REORDER THE ASSOCIATIONS
# ADD ENTRY AND CREATE THE ASSOCIATIONS AT THE END PLEASE.

GROUPS = [
  {label: "Money Matters",           page_class: "money-matters",       bgcolor: "orange"},     #1
  {label: "Health & Fitness",        page_class: "health-fitness",      bgcolor: "darkgreen"},
  {label: "Education & Knowledge",   page_class: "education-knowledge", bgcolor: "pink"},       #3
  {label: "Electronics & Gadgets",   page_class: "electronics-gadgets", bgcolor: "lightblue"},
  {label: "Business & Career",       page_class: "business-career",     bgcolor: "red"},        #5
  {label: "Sports",                  page_class: "sports",              bgcolor: "green"},
  {label: "Entertainment",           page_class: "entertainment",       bgcolor: "blue"},       #7
  {label: "Travel",                  page_class: "travel",              bgcolor: "lightorange"},
  {label: "Lifestyle",               page_class: "lifestyle",           bgcolor: "lightorange"},
  {label: "Food",                    page_class: "food",                bgcolor: "lightgreen"}, #9
  {label: "Current Events",          page_class: "current-events",      bgcolor: "white"}
]

QUESTIONS = [
  {label: "How many hours of sleep do you get on a typical day?", value_type: "hours",         group_id: "2"},       #1
  {label: "How much is your daily budget for food expenditure?",  value_type: "currency",      group_id: "1"},
  {label: "What is your favourite hobby?",                        value_type: "collection",
    options_for_collection: "programming|gaming|studying|soccer|basketball|swimming",          group_id: "4"},                                                                                        #3
  {label: "How many hours in a week do you spend on your hobby?", value_type: "hours",         group_id: "7"},
  {label: "How many hours do you study each day?",                value_type: "hours",         group_id: "3"},       #5
  {label: "On a typical weekday, what time do you wake up?",      value_type: "hours",         group_id: "2"},
  {label: "On a typical weekend, what time do you wake up?",      value_type: "hours",         group_id: "2"},       #7
  {label: "On a typical weekday, what time do you go to sleep?",  value_type: "hours",         group_id: "2"},
  {label: "On a typical weekend, what time do you go to sleep?",  value_type: "hours",         group_id: "2"},       #9
  {label: "How much do you read per day?",                        value_type: "minutes",       group_id: "3"},
  {label: "How much is your tuition?",                            value_type: "currency",      group_id: "3"},       #11
  {label: "How many pets do you currently own?",                  value_type: "quantity",      group_id: "8"},
  {label: "What is your height?",                                 value_type: "measurement",   group_id: "2"},       #13
  {label: "Do you consider eSports to be real sports?",           value_type: "collection",
    options_for_collection: "yes|no",                                                         group_id: "6"},
  {label: "Do you think the movie 'The Interview' have been shown in theatres?", value_type: "collection",
    options_for_collection: "yes|no",                                                         group_id: "7"},       #15
  {label: "Do you keep track of your calorie intake?", value_type: "collection",
    options_for_collection: "yes|no",                                                         group_id: "2"},
  {label: "Given tech startups like Uber and Airbnb are getting high valuations, do you think we are in another tech bubble?", value_type: "collection",
    options_for_collection: "yes|no",                                                         group_id: "5"}
]

# Sample answers for the questions above (orders must match)
SAMPLE_ANSWERS = [8, 10, "misc", 21, 1, 7, 9, 22, 21, 30, 10000]

# Group => Question (based on ordering above)
GROUP_QUESTION_ASSOCIATIONS = [
  {2 => 1},
  {1 => 2},
  {4 => 3},
  {7 => 4},
  {3 => 5},
  {2 => 6},
  {2 => 7},
  {2 => 8},
  {2 => 9},
  {3 => 10},
  {3 => 11},
  {6 => 14},
  {8 => 12},
  {10 => 13},
  {7 => 15},
  {9 => 16},
  {5 => 17}
]

# Create sample user
user = User.create!(
  first_name: "John",
  last_name: "Doe",
  username: "JohnDoe",
  email: "JohnDoe@example.com",
  password: "testaccount",
  gender: "M",
  birthyear: Time.now - 20.years,
  location_attributes: {
    country_code: "CA"
  })

# Create the categories
GROUPS.each do |group|
  Group.create!(label: group[:label], page_class: group[:page_class],
    background_color: group[:bgcolor])
end

# Create the questions
QUESTIONS.each do |question|
  Question.create!(label: question[:label], value_type: question[:value_type],
    options_for_collection: question[:options_for_collection])
end

# Assign questions to their designated categories
GROUP_QUESTION_ASSOCIATIONS.each do |assoc|
  key, value = assoc.first
  GroupsQuestion.create!(group_id: key, question_id: value)
end

# seed the sample answers
SAMPLE_ANSWERS.each_with_index do |ans, idx|
  Answer.create!(question_id: idx + 1, user_id: user.id, value: ans)
end
