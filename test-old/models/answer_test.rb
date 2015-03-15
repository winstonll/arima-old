require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  should belong_to :user
  should belong_to :question
  should validate_presence_of :user_id
  should validate_presence_of :question_id
  should validate_presence_of :value

  def setup
    @ans = FactoryGirl.build(:answer)
  end

  test 'invalid with no attributes' do
    ans = Answer.new
    assert !ans.valid?,
      "Existence of attributes are not being checked"
  end

  test 'invalid without user associtation' do
    @ans.user = nil
    assert !@ans.valid?,
      "User associtation is not being checked"
  end

  test 'invalid without question associtation' do
    @ans.question = nil
    assert !@ans.valid?,
      "Question association is not being checked"
  end

  test 'invalid without value' do
    @ans.value = nil
    assert !@ans.valid?,
      "Existence of the value itself is not being checked"
  end

  test 'valid answer' do
    assert @ans.valid?,
      "Cannot create valid answers!"
  end

  test 'valid categorical answer' do
    q = FactoryGirl.create(:question_collection)
    ans = FactoryGirl.build(:answer, question: q)
    assert ans.valid?,
      "Cannot create valid categorical answer!"
  end

  test 'invalid choice for categorical answer' do
    q = FactoryGirl.create(:question_collection)
    ans = FactoryGirl.build(:answer, question: q)
    ans.value = "Maybe"
    assert !ans.valid?,
      "Can submit choice that does not exist in the collection"
  end

  test 'invalid on duplication resubmission' do
    ans = @ans.dup
    @ans.save
    ans.save
    assert_match /cannot submit duplicate answers/i,
      ans.errors[:question_id].join,
      "Did not prevent creation of duplicate answers!"
  end

  test 'image preview' do
    assert_respond_to @ans, :generate_image,
      "Could not generate image for answers"
  end

end
