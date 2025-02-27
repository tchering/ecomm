require "rails_helper"

RSpec.describe OrderMailer, type: :mailer do
  describe "confirmation" do
    let(:order) { create(:order, number: "ORD-12345", total_amount: 99.99) }
    let(:mail) { OrderMailer.confirmation(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Order Confirmation: ORD-12345")
      expect(mail.to).to eq([order.email])
      expect(mail.from).to eq(["orders@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Thank you for your order")
      expect(mail.body.encoded).to match("ORD-12345")
      expect(mail.body.encoded).to match("99.99")
    end
  end

  describe "status_update" do
    let(:order) { create(:shipped_order, number: "ORD-12345") }
    let(:mail) { OrderMailer.status_update(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Order ORD-12345 Status Update: Shipped")
      expect(mail.to).to eq([order.email])
      expect(mail.from).to eq(["orders@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your order status has been updated")
      expect(mail.body.encoded).to match("ORD-12345")
      expect(mail.body.encoded).to match("shipped")
    end
  end

  describe "shipping_confirmation" do
    let(:order) { create(:shipped_order, number: "ORD-12345", tracking_number: "TRK123456789") }
    let(:mail) { OrderMailer.shipping_confirmation(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your Order ORD-12345 Has Shipped")
      expect(mail.to).to eq([order.email])
      expect(mail.from).to eq(["orders@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your order has been shipped")
      expect(mail.body.encoded).to match("ORD-12345")
      expect(mail.body.encoded).to match("TRK123456789")
    end
  end

  describe "delivery_confirmation" do
    let(:order) { create(:delivered_order, number: "ORD-12345") }
    let(:mail) { OrderMailer.delivery_confirmation(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your Order ORD-12345 Has Been Delivered")
      expect(mail.to).to eq([order.email])
      expect(mail.from).to eq(["orders@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your order has been delivered")
      expect(mail.body.encoded).to match("ORD-12345")
    end
  end

  describe "cancellation" do
    let(:order) { create(:cancelled_order, number: "ORD-12345") }
    let(:mail) { OrderMailer.cancellation(order) }

    it "renders the headers" do
      expect(mail.subject).to eq("Your Order ORD-12345 Has Been Cancelled")
      expect(mail.to).to eq([order.email])
      expect(mail.from).to eq(["orders@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Your order has been cancelled")
      expect(mail.body.encoded).to match("ORD-12345")
    end
  end
end
