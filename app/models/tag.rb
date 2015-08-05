class Tag < ActiveRecord::Base
  belongs_to :questions
  has_many :opinions, :dependent => :destroy
end
