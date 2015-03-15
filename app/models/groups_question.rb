class GroupsQuestion < ActiveRecord::Base
  belongs_to :question
  belongs_to :group

  validates :question_id, uniqueness: { scope: [:group_id, :question_id] }
end