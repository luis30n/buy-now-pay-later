# frozen_string_literal: true

module Merchants
  RSpec.describe CalculateMinMonthlyFeeAmount do
    describe '#call' do
      subject(:service_call) do
        described_class.new(merchant: merchant, date: calculation_date).call
      end

      let(:merchant) { create(:merchant, live_on: live_on_date, minimum_monthly_fee: 100) }
      let(:calculation_date) { Date.parse('2023-10-02') }

      let!(:disbursement1) do
        create(:disbursement, merchant: merchant, created_at: Date.parse('2023-09-10'))
      end
      let!(:fee1) do
        create(:fee, disbursement: disbursement1, amount: 60, created_at: Date.parse('2023-09-10'))
      end

      context 'when the merchant is already live' do
        context 'when the minimum monthly fee has been reached' do
          let!(:disbursement2) do
            create(:disbursement, merchant: merchant, created_at: Date.parse('2023-09-10'))
          end
          let!(:fee2) do
            create(:fee, disbursement: disbursement2, amount: 50, created_at: Date.parse('2023-09-10'))
          end

          let(:live_on_date) { Date.parse('2022-10-10') }

          it 'returns 0' do
            expect(service_call).to eq(0)
          end
        end

        context 'when the minimum monthly fee has not been reached' do
          let(:live_on_date) { Date.parse('2022-10-10') }

          it 'returns the pending minimum monthly fee' do
            expect(service_call).to eq(40)
          end
        end
      end

      context 'when the merchant live_on date is in the same month as calculation date' do
        let(:live_on_date) { calculation_date - 1.day }

        it 'returns 0' do
          expect(service_call).to eq(0)
        end
      end

      context 'when the merchant is not live yet' do
        let(:live_on_date) { Date.parse('2024-10-10') }

        it 'returns 0' do
          expect(service_call).to eq(0)
        end
      end
    end
  end
end
