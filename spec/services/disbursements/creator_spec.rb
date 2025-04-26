# frozen_string_literal: true

RSpec.shared_examples 'a successful disbursement creation' do
  it 'creates a disbursement' do
    expect { creator.call }.to change(Disbursement, :count).by(1)
  end

  it 'sets the right disbursement amount' do
    disbursement = creator.call

    expect(disbursement.amount).to eq(expected_disbursement_amount)
  end

  it 'sets the right regular fee amount' do
    disbursement = creator.call
    regular_fee = disbursement.fees.find_by(category: 'regular')

    expect(regular_fee.amount).to eq(expected_regular_fee_amount)
  end

  it 'creates the required fees' do
    expect { creator.call }.to change(Fee, :count).by(expected_n_fees_created)
  end
end

RSpec.describe Disbursements::Creator do
  subject(:creator) do
    described_class.new(date:, merchant:)
  end
  let(:date) { Date.parse('2023-10-02') }
  let(:merchant) { create(:merchant, disbursement_frequency: 'weekly') }

  describe '#call' do
    let!(:order1) do
      create(:order, merchant:, amount: order1_amount, created_at: Date.parse('2023-09-29'))
    end
    let!(:order2) do
      create(:order, merchant:, amount: order2_amount, created_at: Date.parse('2023-09-28'))
    end
    let!(:order3) do
      create(:order, merchant:, amount: 302, created_at: Date.parse('2023-09-01'))
    end
    let(:order1_amount) { 122 }
    let(:order2_amount) { 30 }
    let(:expected_disbursement_amount) { 150.54 }
    let(:expected_regular_fee_amount) { 1.46 }
    let(:expected_n_fees_created) { 1 }
    let(:calculate_min_monthly_fee_service_mock) do
      instance_double(
        ::Merchants::CalculateMinMonthlyFeeAmount,
        call: min_monthly_fee_amount
      )
    end
    let(:min_monthly_fee_amount) { 100 }
    let(:calculate_regular_amount_service_mock) do
      instance_double(
        ::Fees::CalculateRegularAmount,
        call: expected_regular_fee_amount
      )
    end

    before do
      allow(::Merchants::CalculateMinMonthlyFeeAmount).to receive(:new).and_return(
        calculate_min_monthly_fee_service_mock
      )
      allow(::Fees::CalculateRegularAmount).to receive(:new).and_return(calculate_regular_amount_service_mock)
    end

    context 'when the disbursement is the first of the month' do
      context 'when the minimum monthly fee amount has been reached' do
        let(:min_monthly_fee_amount) { 0 }

        it_behaves_like 'a successful disbursement creation'
      end

      context 'when the minimum monthly fee has not been reached' do
        let(:order1_amount) { 423 }
        let(:order2_amount) { 37 }
        let(:expected_disbursement_amount) { 456.03 }
        let(:expected_regular_fee_amount) { 3.97 }
        let(:expected_n_fees_created) { 2 }

        it_behaves_like 'a successful disbursement creation'

        it 'sets the right min monthly fee amount' do
          disbursement = creator.call
          min_monthly_fee = disbursement.fees.find_by(category: 'min_monthly')

          expect(min_monthly_fee.amount).to eq(min_monthly_fee_amount)
        end
      end
    end

    context 'when the disbursement is not the first of the month' do
      let!(:first_of_month_disbursement) do
        create(:disbursement, merchant:, created_at: Date.parse('2023-10-01'))
      end

      before do
        travel_to Date.parse('2023-10-02')
      end

      it_behaves_like 'a successful disbursement creation'
    end
  end
end
