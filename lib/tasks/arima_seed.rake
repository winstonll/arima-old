namespace :arima do
  task :reset, [:users] => :environment do |t, args|
    args.with_defaults(:users => 100)
    users = args.users.to_i

    Rake::Task['db:reset'].invoke

    User.destroy_all
    Answer.destroy_all
    Question.destroy_all

    ActiveRecord::Base.connection.execute(
      'ALTER SEQUENCE questions_id_seq RESTART WITH 1'
    )

    Rake::Task['arima:seed_demo_data_1'].invoke(users)
 
    # Associate question value
    QUESTION_TYPES = [
      'quantity', 'quantity', 'quantity', 'quantity', 'years',
      'hours', 'hours', 'quantity', 'minutes', 'quantity',
      'quantity', 'currency', 'currency', 'currency', 'currency',
      'quantity', 'collection', 'currency', 'collection', 'quantity',
      'quantity', 'collection', 'collection', 'collection', 'quantity'
    ]
    Question.all.each_with_index do |q, i|
      q.value_type = QUESTION_TYPES[i]
      q.save
    end

    # Randomize location, some combination wouldn't make much sense.
    User.where.not(id: User.last.id).each do |u|
      u.location.country_code = ['CA', 'US'].sample
      u.location.city = ['Toronto', 'New York', 'Waterloo'].sample
      u.save
    end
    
    # Remove group created in seed_demo_data_1
    5.times do |i|
      Group.last.destroy!
    end

    # seed answers
    Rake::Task['arima:seed_demo_data_2'].invoke(users)
  end
end
