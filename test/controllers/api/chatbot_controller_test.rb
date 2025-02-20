require "test_helper"

class Api::ChatbotControllerTest < ActionDispatch::IntegrationTest
  test "should get message" do
    get api_chatbot_message_url
    assert_response :success
  end

  test "should get faqs" do
    get api_chatbot_faqs_url
    assert_response :success
  end
end
