# frozen_string_literal: true

module Orders
  RSpec.describe CalculateRegularFeeAmount do
    subject(:calculate_regular_fee_amount) { described_class.new(orders:) }

    describe '#call' do
      context "when multiple orders are provided" do
        let(:orders) do
          [
            create(:order, amount: 45.34),
            create(:order, amount: 144.87),
            create(:order, amount: 452.97)
          ]
        end
        let(:expected_regular_fee_amount) { 0.45 + 1.38 + 3.85 }

        it 'calculates the regular fee amount for all orders' do
          regular_fee_amount = calculate_regular_fee_amount.call

          expect(regular_fee_amount).to eq(expected_regular_fee_amount)
        end
      end

      context 'when a single order is provided' do
        context 'when amount is lower than 50' do
          let(:orders) { [create(:order, amount: 45.34)] }
          let(:expected_regular_fee_amount) { 0.45 }

          it 'calculates the correct fee amount' do
            regular_fee_amount = calculate_regular_fee_amount.call

            expect(regular_fee_amount).to eq(expected_regular_fee_amount)
          end
        end

        context 'when the total amount is between 50 and 300' do
          let(:orders) { [create(:order, amount: 144.87)] }
          let(:expected_fee_amount) { 1.38 }

          it 'calculates the correct fee amount' do
            regular_fee_amount = calculate_regular_fee_amount.call

            expect(regular_fee_amount).to eq(expected_fee_amount)
          end
        end

        context 'when the total amount is higher or equal to 300' do
          let(:orders) { [create(:order, amount: 452.97)] }
          let(:expected_fee_amount) { 3.85 }

          it 'calculates the correct fee amount' do
            regular_fee_amount = calculate_regular_fee_amount.call

            expect(regular_fee_amount).to eq(expected_fee_amount)
          end
        end
      end
    end
  end
end
