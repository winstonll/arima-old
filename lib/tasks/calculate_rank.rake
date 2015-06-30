
namespace :calculate_rank do
  desc "Calculates ranks for all users"
  task :calculate => :environment do
    arr = User.order('points DESC')
  end
end