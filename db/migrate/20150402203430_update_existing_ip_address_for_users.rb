class UpdateExistingIpAddressForUsers < ActiveRecord::Migration
  def change
    users = User.all
    users.each do |user|
      # Set ip_address default to nil
      user.ip_address = nil
      user.save!
    end
  end
end
