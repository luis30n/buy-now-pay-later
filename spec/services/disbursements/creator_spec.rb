# frozen_string_literal: true

RSpec.shared_examples 'a successful disbursement creation' do
  it 'creates a disbursement' do
    expect { creator.call }.to change(Disbursement, :count).by(1)
  end

  it 'creates the regular fee' do
    expect { creator.call }.to change(Fee.where(category: Fee::REGULAR_CATEGORY), :count).by(1)
  end

  it 'sets the correct regular fee amount' do
    disbursement = creator.call

    regular_fee = disbursement.fees.find_by(category: Fee::REGULAR_CATEGORY)

    expect(regular_fee.amount).to eq(regular_fee_amount)
  end

  it 'sets the correct disbursement amount' do
    disbursement = creator.call

    expect(disbursement.amount).to eq(expected_disbursement_amount)
  end

  it 'associates the orders with the disbursement' do
    disbursement = creator.call

    expect(disbursable_orders_relation_mock).to have_received(:update_all).with(
      disbursement_id: disbursement.id
    )
  end
end

module Disbursements
  RSpec.describe Creator do
    subject(:creator) { described_class.new(date:, merchant: merchant) }

    let(:date) { Date.parse('2023-10-02') }
    let(:merchant) { create(:merchant) }

    let(:disbursable_orders_relation_mock) do
      instance_double(ActiveRecord::Relation, update_all: 2)
    end
    let(:disbursable_orders_query_mock) do
      instance_double(Merchants::DisbursableOrdersQuery, call: disbursable_orders_relation_mock)
    end
    let(:calculate_regular_fee_mock) do
      instance_double(Fees::CalculateRegularAmount, call: regular_fee_amount)
    end
    let(:calculate_min_monthly_fee_mock) do
      instance_double(Merchants::CalculateMinMonthlyFeeAmount, call: min_monthly_fee_amount)
    end
    let(:regular_fee_amount) { BigDecimal('5') }
    let(:expected_disbursement_amount) { BigDecimal('295.0') }
    let(:min_monthly_fee_amount) { 0 }
    let(:disbursable_orders_amounts) do
      [BigDecimal('100.0'), BigDecimal('200.0')]
    end

    before do
      allow(Merchants::DisbursableOrdersQuery).to receive(:new)
        .with(merchant:, date:)
        .and_return(disbursable_orders_query_mock)

      allow(Fees::CalculateRegularAmount).to receive(:new)
        .with(orders: disbursable_orders_relation_mock)
        .and_return(calculate_regular_fee_mock)

      allow(Merchants::CalculateMinMonthlyFeeAmount).to receive(:new)
        .with(merchant:, date:)
        .and_return(calculate_min_monthly_fee_mock)
      allow(disbursable_orders_relation_mock).to receive(:pluck)
        .with(:amount)
        .and_return(disbursable_orders_amounts)
    end

    describe '#call' do
      context 'when min monthly fee amount is 0' do
        let(:min_monthly_fee_amount) { 0 }

        it_behaves_like 'a successful disbursement creation'

        it 'does not create the min monthly fee' do
          expect { creator.call }.not_to change(Fee.where(category: Fee::MIN_MONTHLY_CATEGORY), :count)
        end
      end

      context 'when there is a pending minimum monthly fee' do
        let(:min_monthly_fee_amount) { BigDecimal('100.00') }
        # TODO: Should be 195.0 if we were charging the min monthly fee
        let(:expected_disbursement_amount) { BigDecimal('295.0') }

        context "when disbursement is not the first of the month" do
          it_behaves_like 'a successful disbursement creation'

          it 'does not create the min monthly fee' do
            expect { creator.call }.not_to change(Fee.where(category: Fee::MIN_MONTHLY_CATEGORY), :count)
          end
        end

        context "when disbursement is the first of the month" do
          let(:date) { Date.parse('2023-10-01') }

          it_behaves_like 'a successful disbursement creation'

          it 'creates the min monthly fee' do
            expect { creator.call }.to change(Fee.where(category: Fee::MIN_MONTHLY_CATEGORY), :count)
          end

          it 'sets the right min monthly fee amount' do
            disbursement = creator.call

            min_monthly_fee = disbursement.fees.find_by(category: Fee::MIN_MONTHLY_CATEGORY)

            expect(min_monthly_fee.amount).to eq(min_monthly_fee_amount)
          end
        end
      end
    end
  end
end
