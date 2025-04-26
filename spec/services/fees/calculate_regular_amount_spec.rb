# frozen_string_literal: true

module Fees
  RSpec.describe CalculateRegularAmount do
    describe '#call' do
      subject(:service_call) { described_class.new(orders:).call }

      context 'when there are no disbursable orders' do
        let(:orders) { [] }

        it 'returns 0.00 as BigDecimal' do
          expect(service_call).to eq(BigDecimal('0.00'))
        end
      end

      context 'when there are multiple disbursable orders' do
        let(:order1) { instance_double('Order', fee_amount: BigDecimal('2.50')) }
        let(:order2) { instance_double('Order', fee_amount: BigDecimal('3.75')) }
        let(:order3) { instance_double('Order', fee_amount: BigDecimal('1.25')) }
        let(:orders) { [order1, order2, order3] }

        it 'returns the sum of fee amounts as BigDecimal' do
          expect(service_call).to eq(BigDecimal('7.50'))
        end
      end
    end
  end
end