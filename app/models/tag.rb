class Tag < ActiveRecord::Base
  belongs_to :questions
  had_many :opinions, :dependent => :destroy
end
