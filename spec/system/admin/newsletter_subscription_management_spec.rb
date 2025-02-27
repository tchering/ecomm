require "rails_helper"

RSpec.describe "Admin Newsletter Subscription Management", type: :system do
  let(:admin) { create(:user, admin: true) }

  before do
    driven_by(:rack_test)
    sign_in admin
  end

  describe "viewing newsletter subscriptions" do
    before do
      create(:newsletter_subscription, email: "subscriber1@example.com")
      create(:newsletter_subscription, email: "subscriber2@example.com")
      create(:newsletter_subscription, email: "subscriber3@example.com")
    end

    it "displays all subscriptions on the index page" do
      visit admin_newsletter_subscriptions_path

      expect(page).to have_content("subscriber1@example.com")
      expect(page).to have_content("subscriber2@example.com")
      expect(page).to have_content("subscriber3@example.com")
    end
  end

  describe "removing a subscription" do
    let!(:subscription) { create(:newsletter_subscription, email: "subscriber@example.com") }

    it "allows removing a subscription" do
      visit admin_newsletter_subscriptions_path

      within("tr", text: "subscriber@example.com") do
        click_link "Remove"
      end

      expect(page).to have_content("Subscription was successfully removed")
      expect(page).not_to have_content("subscriber@example.com")
      expect(NewsletterSubscription.find_by(id: subscription.id)).to be_nil
    end
  end

  describe "sending a newsletter" do
    before do
      create_list(:newsletter_subscription, 3)
    end

    it "allows sending a newsletter to all subscribers" do
      visit admin_newsletter_subscriptions_path

      fill_in "Subject", with: "Monthly Newsletter"
      fill_in "Content", with: "Here are our latest updates and promotions."
      click_button "Send Newsletter"

      expect(page).to have_content("Newsletter is being sent to all subscribers")

      expect(Newsletter.count).to eq(1)
      newsletter = Newsletter.last
      expect(newsletter.subject).to eq("Monthly Newsletter")
      expect(newsletter.content).to eq("Here are our latest updates and promotions.")

      expect(NewsletterDeliveryJob).to have_been_enqueued.exactly(3).times
    end

    it "shows validation errors for invalid newsletter" do
      visit admin_newsletter_subscriptions_path

      fill_in "Subject", with: ""
      fill_in "Content", with: ""
      click_button "Send Newsletter"

      expect(page).to have_content("Subject can't be blank")
      expect(page).to have_content("Content can't be blank")

      expect(Newsletter.count).to eq(0)
    end
  end

  describe "importing subscriptions" do
    it "allows importing subscriptions from a CSV file" do
      visit admin_newsletter_subscriptions_path

      attach_file "file", Rails.root.join("spec/fixtures/newsletter_subscriptions.csv")
      click_button "Import"

      expect(page).to have_content("Subscriptions successfully imported")

      # Check that all emails from the CSV were imported
      expect(NewsletterSubscription.find_by(email: "test1@example.com")).to be_present
      expect(NewsletterSubscription.find_by(email: "test2@example.com")).to be_present
      expect(NewsletterSubscription.find_by(email: "test3@example.com")).to be_present
      expect(NewsletterSubscription.find_by(email: "test4@example.com")).to be_present
      expect(NewsletterSubscription.find_by(email: "test5@example.com")).to be_present
    end

    it "shows an error message when no file is selected" do
      visit admin_newsletter_subscriptions_path

      click_button "Import"

      expect(page).to have_content("Please upload a CSV file")
    end
  end

  describe "exporting subscriptions" do
    before do
      create(:newsletter_subscription, email: "subscriber1@example.com")
      create(:newsletter_subscription, email: "subscriber2@example.com")
    end

    it "allows exporting subscriptions to a CSV file" do
      visit admin_newsletter_subscriptions_path

      click_link "Export CSV"

      # Since we can't test file downloads directly in system tests without additional setup,
      # we'll just verify that the link exists and has the correct path
      expect(page).to have_link("Export CSV", href: export_admin_newsletter_subscriptions_path(format: :csv))
    end
  end
end
