# frozen_string_literal: true

module Disbursements
  RSpec.describe ProcessorWorker, type: :job do
    subject(:disbursements_processor) { described_class.new }

    describe '#perform' do
      let!(:daily_merchant) { create(:merchant, disbursement_frequency: 'daily') }
      let!(:monday_weekly_merchant) do
        create(:merchant, live_on: Date.parse('2023-09-18'), disbursement_frequency: 'weekly')
      end
      let!(:tuesday_weekly_merchant) do
        create(:merchant, live_on: Date.parse('2023-09-19'), disbursement_frequency: 'weekly')
      end

      before do
        allow(CreatorWorker).to receive(:perform_async)
      end

      context 'when a date is passed' do
        let(:applicable_merchants) do
          [daily_merchant, tuesday_weekly_merchant]
        end
        let(:tuesday_date) { '2023-09-26' }

        it 'enqueues the creator worker for each merchant', :aggregate_failures do
          disbursements_processor.perform(tuesday_date)

          expect(CreatorWorker).to have_received(:perform_async).with(
            tuesday_date, daily_merchant.id
          ).once

          expect(CreatorWorker).to have_received(:perform_async).with(
            tuesday_date, tuesday_weekly_merchant.id
          ).once
        end
      end

      context 'when a date is not passed' do
        let(:applicable_merchants) do
          [daily_merchant, monday_weekly_merchant]
        end
        let(:monday_date) { '2023-10-02' }

        before do
          travel_to Date.parse(monday_date)
        end

        it 'enqueues the creator worker for each merchant', :aggregate_failures do
          disbursements_processor.perform

          expect(CreatorWorker).to have_received(:perform_async).with(
            monday_date, daily_merchant.id
          ).once

          expect(CreatorWorker).to have_received(:perform_async).with(
            monday_date, monday_weekly_merchant.id
          ).once
        end
      end
    end
  end
end
