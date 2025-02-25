require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:one)
    @user = users(:one)
    sign_in @admin
  end

  test "should get index" do
    get admin_users_path
    assert_response :success
  end

  test "should get show" do
    get admin_user_path(@user)
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_user_path(@user)
    assert_response :success
  end

  test "should update user" do
    patch admin_user_path(@user), params: { user: { first_name: "Updated", last_name: "Name" } }
    assert_redirected_to admin_users_path
    @user.reload
    assert_equal "Updated", @user.first_name
    assert_equal "Name", @user.last_name
  end

  test "should deactivate user" do
    assert_nil @user.deleted_at
    patch deactivate_admin_user_path(@user)
    assert_redirected_to admin_users_path
    @user.reload
    assert_not_nil @user.deleted_at
  end

  test "should filter users by role" do
    get admin_users_path(role: "admin")
    assert_response :success

    get admin_users_path(role: "customer")
    assert_response :success
  end
end
