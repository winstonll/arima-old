class Group < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper

  extend FriendlyId
  friendly_id :label, use: [:slugged, :history], sequence_separator: '_'

  has_many :groups_questions
  has_many :questions, through: :groups_questions

  validates :label, presence: true

  def self.visible_groups(n=3)
    Group.all.sample(n)
  end

  def self.other_groups(exclude_groups)
    Group.all - exclude_groups
  end

  def to_s
    strip_tags self.label
  end

  def self.groups_usage_for_user(user)
    group_ids = user.questions.map(&:groups).map{|g| g.pluck :id}
    group_ids_count = group_ids.flatten.inject(Hash.new(0)){|h,i| h[i] += 1; h }
    group_ids_count.sort_by{|k,v| -v} # highest to lowest
  end

  def self.most_active_group_for_user(user)
    group_id_count = self.groups_usage_for_user(user).first
    return nil unless group_id_count
    group = Group.find(group_id_count[0])
    {group => group_id_count[1]}
  end

  def self.most_active_groups_for_user(user, n=3)
    group_ids_count = self.groups_usage_for_user(user).first(3)
    group_ids_count.map{|gc| {Group.find(gc[0]) => gc[1]}}
  end

  def should_generate_new_friendly_id?
    label_changed?
  end
end
