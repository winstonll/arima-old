class UpdateExistingBirthyearForUsers < ActiveRecord::Migration
  def change
    users = User.all
    users.each do |user|
      if user.dob
        user.birthyear = user.dob.year.to_i
        user.save!
      else
        # Set some default
        user.birthyear = 1965
        user.save!
      end
    end
  end
end
