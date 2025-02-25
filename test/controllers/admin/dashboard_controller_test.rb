require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:one)
    sign_in @admin
  end

  test "should get index" do
    get admin_dashboard_path
    assert_response :success
  end

  test "should get inventory" do
    get admin_inventory_dashboard_path
    assert_response :success
  end
end
