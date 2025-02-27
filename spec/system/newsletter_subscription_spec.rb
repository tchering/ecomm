require "rails_helper"

RSpec.describe "Newsletter Subscriptions", type: :system do
  before do
    driven_by(:rack_test)
  end

  describe "subscribing to the newsletter" do
    it "allows a visitor to subscribe with a valid email" do
      visit root_path

      within("footer") do
        fill_in "newsletter_subscription[email]", with: "subscriber@example.com"
        click_button "Subscribe"
      end

      expect(page).to have_content("You have successfully subscribed to our newsletter")
      expect(NewsletterSubscription.find_by(email: "subscriber@example.com")).to be_present
      expect(NewsletterWelcomeEmailJob).to have_been_enqueued
    end

    it "shows an error message with an invalid email" do
      visit root_path

      within("footer") do
        fill_in "newsletter_subscription[email]", with: "invalid-email"
        click_button "Subscribe"
      end

      expect(page).to have_content("We could not subscribe you to our newsletter")
      expect(NewsletterSubscription.find_by(email: "invalid-email")).to be_nil
    end

    it "shows an error message for a duplicate email" do
      create(:newsletter_subscription, email: "existing@example.com")

      visit root_path

      within("footer") do
        fill_in "newsletter_subscription[email]", with: "existing@example.com"
        click_button "Subscribe"
      end

      expect(page).to have_content("This email is already subscribed to our newsletter")
    end
  end

  describe "unsubscribing from the newsletter" do
    let!(:subscription) { create(:newsletter_subscription) }

    it "allows a subscriber to unsubscribe using their token" do
      visit unsubscribe_newsletter_subscription_path(token: subscription.unsubscribe_token)

      expect(page).to have_content("You have successfully unsubscribed from our newsletter")
      expect(NewsletterSubscription.find_by(id: subscription.id)).to be_nil
    end

    it "shows an error message with an invalid token" do
      visit unsubscribe_newsletter_subscription_path(token: "invalid-token")

      expect(page).to have_content("We could not unsubscribe you from our newsletter")
      expect(NewsletterSubscription.find_by(id: subscription.id)).to be_present
    end
  end
end
