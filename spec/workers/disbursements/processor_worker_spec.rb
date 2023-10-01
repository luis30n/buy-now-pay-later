# frozen_string_literal: true

RSpec.describe Disbursements::ProcessorWorker, type: :job do
  subject(:disbursements_processor) { described_class.new }

  describe '#perform' do
    let!(:daily_merchant) { create(:merchant, disbursement_frequency: 'daily') }
    let!(:monday_weekly_merchant) do
      create(:merchant, live_on: Date.parse('2023-09-18'), disbursement_frequency: 'weekly')
    end
    let!(:tuesday_weekly_merchant) do
      create(:merchant, live_on: Date.parse('2023-09-19'), disbursement_frequency: 'weekly')
    end
    let(:disbursements_creator_class) { ::Services::Disbursements::Creator }
    let(:disbursements_creator_mock) { instance_double(disbursements_creator_class, call: true) }

    before do
      allow(disbursements_creator_class).to receive(:new).and_return(disbursements_creator_mock)
    end

    context 'when a date is passed' do
      let(:applicable_merchants) do
        [daily_merchant, tuesday_weekly_merchant]
      end
      let(:tuesday_date) { '2023-09-26' }

      it 'initializes the disbursement creator for the daily merchants' do
        disbursements_processor.perform(date: tuesday_date)

        expect(disbursements_creator_class).to have_received(:new).with(
          date: Date.parse(tuesday_date), merchant: daily_merchant
        )
      end

      it "initializes the disbursement creator for weekly merchants of the date's weekday" do
        disbursements_processor.perform(date: tuesday_date)

        expect(disbursements_creator_class).to have_received(:new).with(
          date: Date.parse(tuesday_date), merchant: tuesday_weekly_merchant
        )
      end

      it 'calls the disbursement creator once per applicable merchant' do
        disbursements_processor.perform(date: tuesday_date)

        expect(disbursements_creator_mock).to(
          have_received(:call).exactly(applicable_merchants.size).times
        )
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

      it 'initializes the disbursement creator for the daily merchants' do
        disbursements_processor.perform

        expect(disbursements_creator_class).to have_received(:new).with(
          date: Date.parse(monday_date), merchant: daily_merchant
        )
      end

      it "initializes the disbursement creator for weekly merchants of the today's weekday" do
        disbursements_processor.perform

        expect(disbursements_creator_class).to have_received(:new).with(
          date: Date.parse(monday_date), merchant: monday_weekly_merchant
        )
      end

      it 'calls the disbursement creator once per applicable merchant' do
        disbursements_processor.perform

        expect(disbursements_creator_mock).to(
          have_received(:call).exactly(applicable_merchants.size).times
        )
      end
    end
  end
end
