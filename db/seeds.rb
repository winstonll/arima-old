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
  {label: "Travel & Lifestyle",      page_class: "travel-lifestyle",    bgcolor: "lightorange"},
  {label: "Food",                    page_class: "food",                bgcolor: "lightgreen"}, #9
  {label: "Current Events",          page_class: "current-events",      bgcolor: "white"}
]

QUESTIONS = [
  {label: "How many hours of sleep do you get on a typical day?", value_type: "hours"},       #1
  {label: "How much is your daily budget for food expenditure?",  value_type: "currency"},
  {label: "What is your favourite hobby?",                        value_type: "collection",   #3
    options_for_collection: "programming, gaming, studying, soccer, basketball, fishing, swimming, sky-diving, misc"
  },
  {label: "How many hours in a week do you spend on your hobby?", value_type: "hours"},
  {label: "How many hours do you study each day?",                value_type: "hours"},       #5
  {label: "On a typical weekday, what time do you wake up?",      value_type: "hours"},
  {label: "On a typical weekend, what time do you wake up?",      value_type: "hours"},       #7
  {label: "On a typical weekday, what time do you go to sleep?",  value_type: "hours"},
  {label: "On a typical weekend, what time do you go to sleep?",  value_type: "hours"},       #9
  {label: "How much do you read per day?",                        value_type: "minutes"},
  {label: "How much is your tuition?",                            value_type: "currency"},    #11
  {label: "How many pets do you currently own?",                  value_type: "quantity"},
  {label: "What is your height?",                                 value_type: "measurement"},  #13
  {label: "Do you consider eSports to be real sports?",           value_type: "collection",
    options_for_collection: "yes, no" },
  {label: "Do you think the movie 'The Interview' have been shown in theatres?", value_type: "collection",
    options_for_collection: "yes, no" },  #15
  {label: "Do you keep track of your calorie intake?", value_type: "collection",
    options_for_collection: "yes, no" }
]

SAMPLE_ANSWERS = [8, 10, "misc", 21, 1, 7, 9, 22, 21, 30, 10000]

GROUP_QUESTION_ASSOCIATIONS = [
  {1 => 2},
  {1 => 11},
  {2 => 1},
  {2 => 3},
  {2 => 4},
  {2 => 6},
  {2 => 7},
  {2 => 8},
  {2 => 9},
  {3 => 5},
  {3 => 10},
  {3 => 11},
  {4 => 3},
  {4 => 4},
  {5 => 11},
  {6 => 14},
  {7 => 15},
  {8 => 12},
  {9 => 16},
  {10 => 13}
]

FACTS = [
  "#DidYouKnow - 20% of searches on Google each day have never been searched for before.",
  "#DidYouKnow - Almost half the world over three billion people  live on less than $2.50 a day.",
  "#DidYouKnow - 54% of Americans over the age of 18 drink coffee everyday.",
  "#DidYouKnow - The number of languages spoken in the world today is approximately 6900.",
  "#DidYouKnow - Walmart generates $3,000,000.00 in revenues every 7 minutes.",
  "#DidYouKnow - 44% of the adult North American population is single. ",
  "#DidYouKnow - It took the radio 38 years, TV 13 years, and the World Wide Web 4 years to reach 50 million users.",
  "#DidYouKnow - Schubert was the most productive classical composer, writing 7.4 hours of music per year. ",
  "#DidYouKnow - August is the month with the most births, and February the least.",
  "#DidYouKnow - 88% of women find money to be very important in a relationship.",
  "#DidYouKnow - The average person checks their phone 150 times per day.",
  "#DidYouKnow - IT startups have the highest failure rate. Only 37% are still alive after 4 years.",
  "#DidYouKnow - Only 44% of North Americans eat breakfast everyday. ",
  "#DidYouKnow - 90% of all data has been generated over the last two years.",
  "#DidYouKnow - Germany played 99 WorldCup matches (most in history) while Indonesia played only 1 (as Dutch East Indies).",
  "#DidYouKnow - Back in 1998, Google only had 9800 searches per day, now they have more than 6 billion.",
  "#DidYouKnow - Almost half of U.S. CEOs (43%) earn between $100k-$250 a year, and only 2% earn more than $3M per year.",
  "#DidYouKnow - In 1980, the cost of storing 1 gigabyte of information is $437,500, in 2013, it has gone down to $0.05.",
  "#DidYouKnow - The world oldest piece of chewing gum dated back to 7000 BCE. In other words it is 9000 years old.",
  "#DidYouKnow - The average Greek consumes 68.5 lb of cheese per year, by far more than any other country in the world.",
  "#DidYouKnow - The game tree complexity of chess is roughly 10^123 while the # of atoms in the observable universe is only 10^80.",
  "#DidYouKnow - The Beatles is the top selling music artist of all-time by album sales, with 257.7 million certified sales.",
  "#DidYouKnow - The Great Lakes, roughly the same area as the UK, contain 21% of the world's surface fresh water.",
  "#DidYouKnow - 5 billion pizzas are sold each year (or 160 per second), and 3 billion of these are sold in the U.S.",
  "#DidYouKnow - 0.3% of solar energy from the Sahara is enough to power the entire Europe.",
  "#DidYouKnow - 11% of the world's population is left-handed.",
  "#DidYouKnow - The 3 most common languages in the world are Mandarin Chinese, Spanish and English.",
  "#DidYouKnow - The names of all continents both start and end with the same letter",
  "#DidYouKnow - The most commonly used letter in the alphabet is E, and the least used letter is Q.",
  "#DidYouKnow - An average Swiss consumes 10kg (22 lb) of chocolate per year.",
  "#DidYouKnow - Stewardesses is the longest word that is typed with only the left hand. For the right hand, it's lollipop.",
  "#DidYouKnow - The longest street in the world is Yonge street in Toronto (Canada), measuring 1,896 km (1,178 miles).",
  "#DidYouKnow - 1 googol is the number 1 followed by 100 zeros.",
  "#DidYouKnow - The average person laughs 10 times a day.",
  "#DidYouKnow - The average bank teller loses $250 every year.",
  "#DidYouKnow - If your DNA was stretched out, it would reach to the moon 6,000 times.",
  "#DidYouKnow - The average person walks the equivalent of twice around the world in a lifetime.",
  "#DidYouKnow - The word 'almost' is the longest word spelt alphabetically.",
  "#DidYouKnow - The word 'rhythm' is the longest word without a vowel.",
  "#DidYouKnow - The most commonly forgotten item for travelers is their toothbrush.",
  "#DidYouKnow - In developed countries, 27% of food is thrown away.",
  "#DidYouKnow - Over 100 people choke to death on ballpoint pens each year.",
  "#DidYouKnow - More people are allergic to cows milk than any other food."
]

# Create a sample user
user = User.create!(
  first_name: "John",
  last_name: "Doe",
  username: "JohnDoe",
  email: "JohnDoe@example.com",
  password: "arima123456!",
  gender: "M",
  birthyear: Time.now - 20.years,
  # dob: Time.now-20.years,
  location_attributes: {
    country_code: "CA"
  }
)

GROUPS.each do |group|
  Group.create!(label: group[:label], page_class: group[:page_class],
    background_color: group[:bgcolor])
end

QUESTIONS.each do |question|
  Question.create!(label: question[:label], value_type: question[:value_type],
    options_for_collection: question[:options_for_collection])
end

GROUP_QUESTION_ASSOCIATIONS.each do |assoc|
  key, value = assoc.first
  GroupsQuestion.create!(group_id: key, question_id: value)
end

# seed the sample answers
SAMPLE_ANSWERS.each_with_index do |ans, idx|
  Answer.create!(question_id: idx + 1, user_id: user.id, value: ans)
end

FACTS.each do |fact|
  FunFact.create!(description: fact)
end
