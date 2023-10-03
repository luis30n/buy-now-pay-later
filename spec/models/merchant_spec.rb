# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Merchant, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:disbursements).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:orders).dependent(:restrict_with_exception) }
  end

  describe 'validations' do
    it 'defines a disbursement_frequency enum' do
      expect(subject).to define_enum_for(:disbursement_frequency).with_values(
        daily: 'daily',
        weekly: 'weekly'
      ).backed_by_column_of_type(:string)
    end
  end

  describe '#disbursable_orders' do
    subject(:merchant) { create(:merchant, disbursement_frequency:) }
    let(:disbursement) { create(:disbursement) }
    let(:disbursement_frequency) { 'daily' }

    context 'when frequency is daily' do
      let!(:other_undisbursed_order) do
        create(:order, disbursement: nil, merchant:, created_at: 3.days.ago)
      end
      let!(:yesterday_disbursed_order) do
        create(:order, disbursement:, merchant:, created_at: Date.yesterday)
      end
      let(:yesterday_undisbursed_orders) do
        create_list(:order, 2, disbursement: nil, merchant:, created_at: Date.yesterday)
      end

      it 'returns the undisbursed orders from yesterday' do
        expect(
          merchant.disbursable_orders(date: Date.today)
        ).to eq(yesterday_undisbursed_orders)
      end
    end

    context 'when frequency is weekly' do
      let(:disbursement_frequency) { 'weekly' }
      let!(:last_week_disbursed_order1) do
        create(:order, disbursement:, merchant:, created_at: 3.days.ago)
      end
      let(:last_week_undisbursed_order1) do
        create(:order, disbursement: nil, merchant:, created_at: Date.yesterday)
      end
      let(:last_week_undisbursed_order2) do
        create(:order, disbursement: nil, merchant:, created_at: 2.days.ago)
      end

      it 'returns the undisbursed orders from last week' do
        expect(
          merchant.disbursable_orders(date: Date.today)
        ).to eq([last_week_undisbursed_order1, last_week_undisbursed_order2])
      end
    end
  end

  describe '#pending_min_monthly_fee_amount' do
    subject(:merchant) { create(:merchant, live_on: live_on_date, minimum_monthly_fee: 100) }

    let!(:disbursement1) do
      create(:disbursement, merchant:, created_at: Date.parse('2023-09-10'))
    end
    let!(:fee1) do
      create(:fee, disbursement: disbursement1, amount: 60, created_at: Date.parse('2023-09-10'))
    end
    let(:live_on_date) { Date.parse('2022-10-10') }
    let(:calculation_date)  { Date.parse('2023-10-02') }

    context 'when the merchant is already live' do
      context 'when the minimum monthly fee has been reached' do
        let!(:disbursement2) do
          create(:disbursement, merchant:, created_at: Date.parse('2023-09-10'))
        end
        let!(:fee2) do
          create(
            :fee,
            disbursement: disbursement2,
            amount: 50,
            created_at: Date.parse('2023-09-10')
          )
        end

        it 'returns 0' do
          expect(merchant.pending_min_monthly_fee_amount(date: calculation_date)).to eq 0
        end
      end

      context 'when the minimum monthly fee has not been reached' do
        it 'returns the pending min monthly fee' do
          expect(merchant.pending_min_monthly_fee_amount(date: calculation_date)).to eq 40
        end
      end
    end

    context 'when the merchant live on date is in the same month' do
      let(:live_on_date) { calculation_date - 1.days }

      it 'returns the pending min monthly fee' do
        expect(merchant.pending_min_monthly_fee_amount(date: calculation_date)).to eq 0
      end
    end

    context 'when the merchant is not live yet' do
      let(:live_on_date) { Date.parse('2024-10-10') }

      it 'returns the pending min monthly fee' do
        expect(merchant.pending_min_monthly_fee_amount(date: calculation_date)).to eq 0
      end
    end
  end
end
