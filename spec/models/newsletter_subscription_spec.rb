require "rails_helper"

RSpec.describe NewsletterSubscription, type: :model do
  describe "validations" do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("invalid-email").for(:email) }
    it { should validate_uniqueness_of(:token).allow_nil }
  end

  describe "callbacks" do
    it "generates a token before create" do
      subscription = create(:newsletter_subscription)
      expect(subscription.token).to be_present
    end

    it "sets defaults before create" do
      subscription = create(:newsletter_subscription, active: nil)
      expect(subscription.active).to be true
      expect(subscription.subscribed_at).to be_present
    end
  end

  describe "scopes" do
    before do
      create(:newsletter_subscription, active: true)
      create(:newsletter_subscription, active: false)
    end

    it "returns active subscriptions" do
      expect(NewsletterSubscription.active.count).to eq(1)
    end

    it "returns inactive subscriptions" do
      expect(NewsletterSubscription.inactive.count).to eq(1)
    end
  end

  describe "#subscribe!" do
    let(:subscription) { create(:newsletter_subscription, active: false, unsubscribed_at: 1.day.ago) }

    it "activates the subscription" do
      subscription.subscribe!
      expect(subscription.active).to be true
      expect(subscription.subscribed_at).to be_present
      expect(subscription.unsubscribed_at).to be_nil
    end
  end

  describe "#unsubscribe!" do
    let(:subscription) { create(:newsletter_subscription, active: true) }

    it "deactivates the subscription" do
      subscription.unsubscribe!
      expect(subscription.active).to be false
      expect(subscription.unsubscribed_at).to be_present
    end
  end

  describe ".find_by_token" do
    let!(:subscription) { create(:newsletter_subscription) }

    it "finds subscription by token" do
      expect(NewsletterSubscription.find_by_token(subscription.token)).to eq(subscription)
    end

    it "returns nil for invalid token" do
      expect(NewsletterSubscription.find_by_token("invalid-token")).to be_nil
    end
  end
end
