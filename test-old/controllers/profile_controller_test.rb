require 'test_helper'

class ProfileControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @controller = ProfilesController.new
    @user = FactoryGirl.create(:user)
    @bad_user = FactoryGirl.create(:user, gender: nil)
  end

  test "should get show" do
    # guest
    get :show
    assert_redirected_to new_user_session_path,
      "visitor did not get redirect back to sign-in page"

    # member
    sign_in(@user)
    get :show
    assert_response :success,
      "Member cannot reach their own profile page!"

    # user that haven't properly setup profile
    sign_in(@bad_user)
    get :show
    assert_redirected_to getting_started_path,
      "non-setup user did not get redirect back to the getting started widget"
  end

  test "should get update" do
    get :update
    assert_redirected_to new_user_session_path,
      "visitor did not get redirect back to sign-in page"

    sign_in(@user)
    get :update, :user => {
      :username => 'abc123',
      :first_name => 'first',
      :last_name => 'last',
      :location_attributes => {}
    }
    assert_redirected_to profile_path,
      "Member not being redirected to their profile page"

    sign_in(@bad_user)
    get :update
    assert_redirected_to getting_started_path,
      "non-setup user did not get redirect back to the getting started widget"
  end

end
