require "rails_helper"

RSpec.describe Product, type: :model do
  describe "validations" do
    it { should validate_numericality_of(:tax_rate).is_greater_than_or_equal_to(0).allow_nil }
    it { should validate_numericality_of(:tax_rate).is_less_than_or_equal_to(100).allow_nil }
  end

  describe "associations" do
    it { should belong_to(:category) }
    it { should have_many_attached(:images) }
    it { should have_many(:stocks).dependent(:destroy) }
    it { should have_many(:product_orders) }
    it { should have_many(:orders).through(:product_orders) }
  end

  describe "#effective_tax_rate" do
    let(:category) { create(:category, tax_rate: 10.0) }

    context "when product has its own tax rate" do
      let(:product) { create(:product, category: category, tax_rate: 15.0) }

      it "returns the product tax rate" do
        expect(product.effective_tax_rate).to eq(15.0)
      end
    end

    context "when product has no tax rate" do
      let(:product) { create(:product, category: category, tax_rate: nil) }

      it "returns the category tax rate" do
        expect(product.effective_tax_rate).to eq(10.0)
      end
    end
  end

  describe "#calculate_tax" do
    let(:category) { create(:category, tax_rate: 10.0) }
    let(:product) { create(:product, category: category) }
    let(:price) { 100.0 }

    it "calculates the correct tax amount" do
      expected_tax = price * (category.tax_rate / 100.0)
      expect(product.calculate_tax(price)).to eq(expected_tax)
    end
  end

  describe "#price_with_tax" do
    let(:category) { create(:category, tax_rate: 10.0) }
    let(:product) { create(:product, category: category) }
    let(:price) { 100.0 }

    it "returns the price including tax" do
      tax_amount = price * (category.tax_rate / 100.0)
      expected_total = price + tax_amount
      expect(product.price_with_tax(price)).to eq(expected_total)
    end
  end

  describe "factory" do
    it "has a valid factory" do
      expect(build(:product)).to be_valid
    end

    it "has a valid factory with images" do
      expect(build(:product, :with_images)).to be_valid
    end

    it "has a valid factory when inactive" do
      expect(build(:product, :inactive)).to be_valid
    end

    it "has a valid factory with tax rate" do
      expect(build(:product, :with_tax_rate)).to be_valid
    end
  end
end
