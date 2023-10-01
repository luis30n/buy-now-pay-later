# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'a correct fee amount calculation' do
  it 'returns the correct fee amount' do
    expect(order.fee_amount).to eq(expected_fee_amount)
  end
end

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:disbursement).optional(true) }
    it { is_expected.to belong_to(:merchant) }
  end

  describe '.undisbursed' do
    let!(:disbursed_orders) { create_list(:order, 3, disbursement: build(:disbursement)) }
    context 'when some orders are not disbursed' do
      let!(:undisbursed_orders) { create_list(:order, 2, disbursement: nil) }

      it 'returns the undisbursed orders' do
        expect(described_class.undisbursed).to eq(undisbursed_orders)
      end
    end

    context 'when all orders are disbursed' do
      it 'returns an empty collection' do
        expect(described_class.undisbursed).to be_empty
      end
    end
  end

  describe '#fee_amount' do
    subject(:order) { create(:order, amount:) }
    context 'when amount is lower than 50' do
      let(:amount) { 45.34 }
      let(:expected_fee_amount) { 0.45 }

      it_behaves_like 'a correct fee amount calculation'
    end

    context 'when the total amount is between 50 and 300' do
      let(:amount) { 144.87 }
      let(:expected_fee_amount) { 1.38 }

      it_behaves_like 'a correct fee amount calculation'
    end

    context 'when the total amount is higher or equal to 300' do
      let(:amount) { 452.97 }
      let(:expected_fee_amount) { 3.85 }

      it_behaves_like 'a correct fee amount calculation'
    end
  end
end
