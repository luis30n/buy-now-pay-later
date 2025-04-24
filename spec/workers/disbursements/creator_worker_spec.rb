# frozen_string_literal: true

module Disbursements
  RSpec.describe CreatorWorker do
    subject(:creator_worker) { described_class.new }

    let(:date) { '2023-09-26' }
    let(:merchant) { create(:merchant) }
    let(:disbursement_creator_mock) { instance_double(Disbursements::Creator, call: true) }

    before do
      allow(Disbursements::Creator).to receive(:new).and_return(disbursement_creator_mock)
    end

    describe '#perform' do
      context 'when the merchant exists' do
        it 'calls the creator service' do
          creator_worker.perform(date, merchant.id)

          expect(Disbursements::Creator).to have_received(:new).with(
            date:,
            merchant:
          )
          expect(disbursement_creator_mock).to have_received(:call)
        end
      end

      context 'when the merchant does not exist' do
        before do
          allow(Rails.logger).to receive(:info)
        end

        it 'logs a message' do
          creator_worker.perform(date, -1)

          expect(Rails.logger).to have_received(:info).with('Merchant with ID -1 not found.')
        end

        it 'does not call the creator service' do
          creator_worker.perform(date, -1)

          expect(Disbursements::Creator).not_to have_received(:new)
          expect(disbursement_creator_mock).not_to have_received(:call)
        end
      end
    end
  end
end
