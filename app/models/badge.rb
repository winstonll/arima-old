class Badge < ActiveRecord::Base
  belongs_to :users
  has_many :users
end
