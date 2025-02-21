require 'rails_helper'

RSpec.describe Category, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:tax_rate) }
    it { should validate_numericality_of(:tax_rate).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:tax_rate).is_less_than_or_equal_to(100) }
  end

  describe 'associations' do
    it { should have_many(:products) }
    it { should have_one_attached(:image) }
  end

  describe 'factory' do
    it 'has a valid factory' do
      expect(build(:category)).to be_valid
    end

    it 'has a valid factory with image' do
      expect(build(:category, :with_image)).to be_valid
    end
  end
end
