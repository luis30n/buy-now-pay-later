# frozen_string_literal: true

require 'spec_helper'

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
end
