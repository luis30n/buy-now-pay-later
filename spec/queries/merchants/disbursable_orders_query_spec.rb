# frozen_string_literal: true

module Merchants
  RSpec.describe DisbursableOrdersQuery do
    describe '#call' do
      subject(:query) { described_class.new(merchant:, date: Date.today) }

      let(:merchant) { create(:merchant, disbursement_frequency:) }
      let(:disbursement) { create(:disbursement) }
      let(:disbursement_frequency) { Merchant::DAILY_FREQUENCY }

      context 'when frequency is daily' do
        let!(:other_undisbursed_order) do
          create(:order, disbursement: nil, merchant:, created_at: 3.days.ago)
        end
        let!(:yesterday_disbursed_order) do
          create(:order, disbursement:, merchant:, created_at: Date.yesterday)
        end
        let!(:yesterday_undisbursed_orders) do
          create_list(:order, 2, disbursement: nil, merchant:, created_at: Date.yesterday)
        end

        it 'returns the undisbursed orders from yesterday' do
          expect(query.call).to match_array(yesterday_undisbursed_orders)
        end
      end

      context 'when frequency is weekly' do
        let(:disbursement_frequency) { Merchant::WEEKLY_FREQUENCY }

        let!(:last_week_disbursed_order) do
          create(:order, disbursement:, merchant:, created_at: 6.days.ago)
        end
        let!(:last_week_undisbursed_order1) do
          create(:order, disbursement: nil, merchant:, created_at: 2.days.ago)
        end
        let!(:last_week_undisbursed_order2) do
          create(:order, disbursement: nil, merchant:, created_at: 1.day.ago)
        end

        it 'returns the undisbursed orders from the past week' do
          expect(query.call).to match_array([last_week_undisbursed_order1, last_week_undisbursed_order2])
        end
      end
    end
  end
end
