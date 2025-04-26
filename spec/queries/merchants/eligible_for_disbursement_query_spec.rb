# frozen_string_literal: true

module Merchants
  RSpec.describe EligibleForDisbursementQuery do
    subject(:eligible_for_disbursements_query) { described_class.new(date:) }

    let(:date) { "2023-10-01" }
    let!(:daily_merchant) { create(:merchant, disbursement_frequency: Merchant::DAILY_FREQUENCY) }
    let!(:weekly_merchant) { create(:merchant, live_on: date.to_date - 7.days, disbursement_frequency: Merchant::WEEKLY_FREQUENCY) }
    let!(:weekly_merchant_with_different_live_on) do
      create(:merchant, disbursement_frequency: Merchant::WEEKLY_FREQUENCY, live_on: Date.new(2023, 10, 2))
    end

    describe '#call' do
      it 'returns daily merchants and suitable weekly ones' do
        eligible_merchants = eligible_for_disbursements_query.call

        expect(eligible_merchants).to match_array([daily_merchant, weekly_merchant])
      end
    end
  end
end
