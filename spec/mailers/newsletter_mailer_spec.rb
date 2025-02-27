require "rails_helper"

RSpec.describe NewsletterMailer, type: :mailer do
  describe "welcome_email" do
    let(:subscription) { create(:newsletter_subscription) }
    let(:mail) { NewsletterMailer.welcome_email(subscription) }

    it "renders the headers" do
      expect(mail.subject).to eq("Welcome to Our Newsletter")
      expect(mail.to).to eq([subscription.email])
      expect(mail.from).to eq(["notifications@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Thank you for subscribing to our newsletter")
      expect(mail.body.encoded).to match(subscription.unsubscribe_token)
    end
  end

  describe "newsletter_email" do
    let(:subscription) { create(:newsletter_subscription) }
    let(:newsletter) { create(:newsletter, subject: "Monthly Updates", content: "Here are our latest updates.") }
    let(:mail) { NewsletterMailer.newsletter_email(newsletter, subscription) }

    it "renders the headers" do
      expect(mail.subject).to eq("Monthly Updates")
      expect(mail.to).to eq([subscription.email])
      expect(mail.from).to eq(["notifications@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Here are our latest updates.")
      expect(mail.body.encoded).to match(subscription.unsubscribe_token)
    end
  end
end
