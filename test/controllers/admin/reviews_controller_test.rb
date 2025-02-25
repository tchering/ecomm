require "test_helper"

class Admin::ReviewsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = admins(:one)
    @review = reviews(:one)
    sign_in @admin
  end

  test "should get index" do
    get admin_reviews_path
    assert_response :success
  end

  test "should get show" do
    get admin_review_path(@review)
    assert_response :success
  end

  test "should update review" do
    patch admin_review_path(@review), params: { review: { title: "Updated Title" } }
    assert_redirected_to admin_review_path(@review)
    @review.reload
    assert_equal "Updated Title", @review.title
  end

  test "should destroy review" do
    assert_difference("Review.count", -1) do
      delete admin_review_path(@review)
    end
    assert_redirected_to admin_reviews_path
  end

  test "should approve review" do
    @review.update(approved: nil)
    patch approve_admin_review_path(@review)
    assert_redirected_to admin_reviews_path
    @review.reload
    assert @review.approved
  end

  test "should reject review" do
    @review.update(approved: nil)
    patch reject_admin_review_path(@review)
    assert_redirected_to admin_reviews_path
    @review.reload
    assert_not @review.approved
  end

  test "should filter reviews by status" do
    get admin_reviews_path(status: 'pending')
    assert_response :success

    get admin_reviews_path(status: 'approved')
    assert_response :success

    get admin_reviews_path(status: 'rejected')
    assert_response :success
  end
end
