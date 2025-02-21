require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe '#total_price' do
    let(:cart_item) { create(:cart_item, quantity: 3, price: 10.0) }

    it 'calculates the total price' do
      expect(cart_item.total_price).to eq(30.0)
    end
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:cart_item)).to be_valid
    end
  end
end
