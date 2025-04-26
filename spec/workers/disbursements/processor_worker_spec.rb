# frozen_string_literal: true

module Disbursements
  RSpec.describe ProcessorWorker, type: :job do
    subject(:disbursements_processor) { described_class.new }

    describe '#perform' do
      let!(:daily_merchant) { create(:merchant, disbursement_frequency: Merchant::DAILY_FREQUENCY) }
      let!(:monday_weekly_merchant) do
        create(:merchant, live_on: Date.parse('2023-09-18'), disbursement_frequency: Merchant::WEEKLY_FREQUENCY)
      end
      let!(:tuesday_weekly_merchant) do
        create(:merchant, live_on: Date.parse('2023-09-19'), disbursement_frequency: Merchant::WEEKLY_FREQUENCY)
      end
      let(:eligible_mechants_query_mock) do
        instance_double(::Merchants::EligibleForDisbursementQuery, call: eligible_merchants_collection_mock)
      end
      let(:eligible_merchants_collection_mock) do
        instance_double(ActiveRecord::Relation)
      end

      before do
        allow(CreatorWorker).to receive(:perform_async)
        allow(::Merchants::EligibleForDisbursementQuery).to receive(:new).and_return(
          eligible_mechants_query_mock
        )
        allow(eligible_merchants_collection_mock).to receive(:pluck).and_return(
          [daily_merchant.id, monday_weekly_merchant.id, tuesday_weekly_merchant.id]
        )
      end

      context 'when a date is passed' do
        let(:eligible_merchants) do
          [daily_merchant, tuesday_weekly_merchant]
        end
        let(:tuesday_date) { '2023-09-26' }

        before do
          allow(eligible_merchants_collection_mock).to receive(:find_each).and_yield(daily_merchant).and_yield(
            tuesday_weekly_merchant
          )
        end

        it 'enqueues the disbursement creator for the eligible merchants', :aggregate_failures do
          disbursements_processor.perform(tuesday_date)

          expect(CreatorWorker).to have_received(:perform_async).with(
            tuesday_date, daily_merchant.id
          )
          expect(CreatorWorker).to have_received(:perform_async).with(
            tuesday_date, tuesday_weekly_merchant.id
          )
        end

        it 'calls the eligible merchants query with the passed date', :aggregate_failures do
          disbursements_processor.perform(tuesday_date)

          expect(::Merchants::EligibleForDisbursementQuery).to have_received(:new)
            .with(date: tuesday_date)
          expect(eligible_mechants_query_mock).to have_received(:call)
        end
      end

      context 'when a date is not passed' do
        let(:eligible_merchants) do
          [daily_merchant, monday_weekly_merchant]
        end
        let(:monday_date) { '2023-10-02' }

        before do
          travel_to Date.parse(monday_date)
          allow(eligible_merchants_collection_mock).to receive(:find_each).and_yield(daily_merchant).and_yield(
            monday_weekly_merchant
          )
        end

        it 'enqueues the disbursement creator for the eligible merchants', :aggregate_failures do
          disbursements_processor.perform(monday_date)

          expect(CreatorWorker).to have_received(:perform_async).with(
            monday_date, daily_merchant.id
          )
          expect(CreatorWorker).to have_received(:perform_async).with(
            monday_date, monday_weekly_merchant.id
          )
        end

        it "calls the eligible merchants query with today's date", :aggregate_failures do
          disbursements_processor.perform

          expect(::Merchants::EligibleForDisbursementQuery).to have_received(:new)
            .with(date: monday_date)
          expect(eligible_mechants_query_mock).to have_received(:call)
        end
      end
    end
  end
end
