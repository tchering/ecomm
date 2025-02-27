require "rails_helper"

RSpec.describe ContactInquiry, type: :model do
  describe "associations" do
    it { should have_many(:contact_responses).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:subject) }
    it { should validate_presence_of(:message) }
    it { should allow_value("user@example.com").for(:email) }
    it { should_not allow_value("invalid-email").for(:email) }
  end

  describe "enums" do
    it { should define_enum_for(:status).with_values(new: 0, in_progress: 1, resolved: 2, spam: 3) }
  end

  describe "callbacks" do
    it "sets default status before create" do
      inquiry = create(:contact_inquiry, status: nil)
      expect(inquiry.status).to eq("new")
    end
  end

  describe "scopes" do
    describe ".unresolved" do
      it "returns inquiries that are not resolved" do
        resolved = create(:contact_inquiry, status: :resolved)
        pending = create(:contact_inquiry, status: :pending)
        in_progress = create(:contact_inquiry, status: :in_progress)

        unresolved = ContactInquiry.unresolved
        expect(unresolved).to include(pending, in_progress)
        expect(unresolved).not_to include(resolved)
      end
    end

    it "returns recent inquiries" do
      expect(ContactInquiry.recent.first.status).to eq("resolved")
    end
  end

  describe "instance methods" do
    describe "#mark_as_resolved!" do
      let(:inquiry) { create(:contact_inquiry, status: :pending) }

      it "marks the inquiry as resolved" do
        inquiry.mark_as_resolved!
        expect(inquiry.reload).to be_resolved
        expect(inquiry.resolved_at).to be_present
      end
    end

    describe "#mark_as_in_progress!" do
      let(:inquiry) { create(:contact_inquiry, status: :pending) }

      it "marks the inquiry as in progress" do
        inquiry.mark_as_in_progress!
        expect(inquiry.reload).to be_in_progress
      end
    end

    describe "#mark_as_spam!" do
      let(:inquiry) { create(:contact_inquiry, status: :pending) }

      it "marks the inquiry as spam" do
        inquiry.mark_as_spam!
        expect(inquiry.reload).to be_spam
      end
    end
  end
end
