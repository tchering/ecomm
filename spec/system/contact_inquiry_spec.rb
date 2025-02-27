require "rails_helper"

RSpec.describe "Contact Inquiries", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "submitting a contact inquiry" do
    it "allows a visitor to submit a valid inquiry" do
      visit new_contact_inquiry_path

      fill_in "Name", with: "Jane Doe"
      fill_in "Email", with: "jane@example.com"
      fill_in "Subject", with: "Product Question"
      fill_in "Message", with: "I have a question about your products."

      click_button "Submit"

      expect(page).to have_content("Your inquiry has been successfully submitted")

      inquiry = ContactInquiry.last
      expect(inquiry.name).to eq("Jane Doe")
      expect(inquiry.email).to eq("jane@example.com")
      expect(inquiry.subject).to eq("Product Question")
      expect(inquiry.message).to eq("I have a question about your products.")
      expect(inquiry.status).to eq("new")

      expect(ContactInquiryNotificationJob).to have_been_enqueued
    end

    it "shows validation errors for invalid submissions" do
      visit new_contact_inquiry_path

      # Submit without filling in any fields
      click_button "Submit"

      expect(page).to have_content("Name can't be blank")
      expect(page).to have_content("Email can't be blank")
      expect(page).to have_content("Subject can't be blank")
      expect(page).to have_content("Message can't be blank")

      # No inquiry should be created
      expect(ContactInquiry.count).to eq(0)
    end
  end
end
