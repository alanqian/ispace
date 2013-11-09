require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  fixtures :users

  setup do
    @user_attrs = {
      username: 'test_attr',
      employee_id: '10088',
      email: 'test_email@g.cn',
      password: '00000000',
      password_confirmation: '00000000'
    }
  end

  test "should get show" do
  end

  test "should get update" do
    patch :update, id: @user, user: { telephone: '13810223997' }
    assert_redirected_to edit_user_path(@user)
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should get create" do
    assert_difference "User.count", 1 do
      post :create, user: @user_attrs
    end
    assert_redirected_to users_path
  end

  test "should get destroy" do
  end

end