require "rails_helper"

RSpec.describe ContactMailer, type: :mailer do
  describe "admin_notification" do
    let(:inquiry) { create(:contact_inquiry, name: "John Smith", email: "john@example.com", subject: "Product Question", message: "I have a question about your products.") }
    let(:mail) { ContactMailer.admin_notification(inquiry) }

    it "renders the headers" do
      expect(mail.subject).to eq("New Contact Inquiry: Product Question")
      expect(mail.to).to eq(["admin@example.com"])
      expect(mail.from).to eq(["notifications@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("John Smith")
      expect(mail.body.encoded).to match("john@example.com")
      expect(mail.body.encoded).to match("Product Question")
      expect(mail.body.encoded).to match("I have a question about your products.")
    end
  end

  describe "inquiry_response" do
    let(:inquiry) { create(:contact_inquiry, name: "John Smith", email: "john@example.com", subject: "Product Question") }
    let(:response) { create(:contact_response, contact_inquiry: inquiry, message: "Thank you for your inquiry. We'll get back to you soon.") }
    let(:mail) { ContactMailer.inquiry_response(response) }

    it "renders the headers" do
      expect(mail.subject).to eq("Re: Product Question")
      expect(mail.to).to eq(["john@example.com"])
      expect(mail.from).to eq(["support@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Thank you for your inquiry. We'll get back to you soon.")
      expect(mail.body.encoded).to match("John Smith")
      expect(mail.body.encoded).to match("Product Question")
    end
  end
end
