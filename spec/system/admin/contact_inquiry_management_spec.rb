require "rails_helper"

RSpec.describe "Admin Contact Inquiry Management", type: :system do
  let(:admin) { create(:user, admin: true) }

  before do
    driven_by(:rack_test)
    sign_in admin
  end

  describe "viewing contact inquiries" do
    before do
      create(:contact_inquiry, name: "John Smith", subject: "Order Issue", status: :pending)
      create(:contact_inquiry, name: "Jane Doe", subject: "Product Question", status: :resolved)
      create(:contact_inquiry, name: "Bob Wilson", subject: "Spam Message", status: :spam)
    end

    it "displays all inquiries on the index page" do
      visit admin_contact_inquiries_path

      expect(page).to have_content("John Smith")
      expect(page).to have_content("Jane Doe")
      expect(page).to have_content("Bob Wilson")

      expect(page).to have_content("Order Issue")
      expect(page).to have_content("Product Question")
      expect(page).to have_content("Spam Message")

      expect(page).to have_content("Pending")
      expect(page).to have_content("Resolved")
      expect(page).to have_content("Spam")
    end

    it "filters inquiries by status" do
      visit admin_contact_inquiries_path

      click_link "Pending"

      expect(page).to have_content("John Smith")
      expect(page).not_to have_content("Jane Doe")
      expect(page).not_to have_content("Bob Wilson")

      click_link "Resolved"

      expect(page).not_to have_content("John Smith")
      expect(page).to have_content("Jane Doe")
      expect(page).not_to have_content("Bob Wilson")

      click_link "Spam"

      expect(page).not_to have_content("John Smith")
      expect(page).not_to have_content("Jane Doe")
      expect(page).to have_content("Bob Wilson")

      click_link "All"

      expect(page).to have_content("John Smith")
      expect(page).to have_content("Jane Doe")
      expect(page).to have_content("Bob Wilson")
    end
  end

  describe "viewing a single inquiry" do
    let!(:inquiry) { create(:contact_inquiry, name: "John Smith", email: "john@example.com", subject: "Order Issue", message: "I have an issue with my order #12345.") }

    it "displays the inquiry details" do
      visit admin_contact_inquiry_path(inquiry)

      expect(page).to have_content("Order Issue")
      expect(page).to have_content("John Smith")
      expect(page).to have_content("john@example.com")
      expect(page).to have_content("I have an issue with my order #12345.")
    end
  end

  describe "updating inquiry status" do
    let!(:inquiry) { create(:contact_inquiry, status: :pending) }

    it "allows changing the status" do
      visit admin_contact_inquiry_path(inquiry)

      select "Resolved", from: "Status"
      click_button "Update Status"

      expect(page).to have_content("Contact inquiry was successfully updated")
      expect(inquiry.reload.status).to eq("resolved")
    end
  end

  describe "responding to an inquiry" do
    let!(:inquiry) { create(:contact_inquiry, name: "John Smith", email: "john@example.com") }

    it "allows sending a response" do
      visit admin_contact_inquiry_path(inquiry)

      fill_in "Message", with: "Thank you for your inquiry. We'll look into this right away."
      click_button "Send Response"

      expect(page).to have_content("Response sent successfully")

      inquiry.reload
      expect(inquiry.status).to eq("resolved")
      expect(inquiry.resolved_at).not_to be_nil
      expect(inquiry.contact_responses.count).to eq(1)
      expect(inquiry.contact_responses.first.message).to eq("Thank you for your inquiry. We'll look into this right away.")

      expect(ContactResponseEmailJob).to have_been_enqueued
    end

    it "shows validation errors for invalid responses" do
      visit admin_contact_inquiry_path(inquiry)

      fill_in "Message", with: ""
      click_button "Send Response"

      expect(page).to have_content("Message can't be blank")

      inquiry.reload
      expect(inquiry.status).not_to eq("resolved")
      expect(inquiry.contact_responses.count).to eq(0)
    end
  end

  describe "marking an inquiry as resolved" do
    let!(:inquiry) { create(:contact_inquiry, status: :pending) }

    it "allows marking an inquiry as resolved" do
      visit admin_contact_inquiries_path

      within "#contact-inquiry-#{inquiry.id}" do
        click_button "Mark as Resolved"
      end

      expect(page).to have_content("Inquiry was marked as resolved")
      expect(inquiry.reload.resolved?).to be true
    end
  end
end
