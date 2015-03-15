require 'test_helper'

class CategoriesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user = FactoryGirl.create(:user)
  end

  test "should get index" do
    sign_in(@user)
    get :index
    assert_response :success
  end

  test "should get show" do
    sign_in(@user)
    get :show, :id => FactoryGirl.create(:group)
    assert_response :success
  end

end
