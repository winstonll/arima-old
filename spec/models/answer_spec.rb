require 'rails_helper'

RSpec.describe Answer, :type => :model do
  it { should belong_to(:user) }
  it { should belong_to(:question) }
  it { should validate_presence_of(:value) }

  context 'with a negative value' do
    it 'should not be valid' do
      question = FactoryGirl.build(:question, value_type: 'numerical')
      answer = question.answers.build(value: -1)
      expect(answer).not_to be_valid
    end
  end
end
