# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Disbursement, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:merchant) }
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:fees) }
  end

  describe '#first_of_month?' do
    let(:disbursement) { create(:disbursement, merchant:) }

    subject { disbursement }

    context 'when merchant is weekly' do
      let(:merchant) { create(:merchant, disbursement_frequency: Merchant::WEEKLY_FREQUENCY) }

      context 'when date is exactly the first day of the month' do
        it 'returns true' do
          expect(subject.first_of_month?(date: Date.parse('2023-09-01'))).to eq(true)
        end
      end

      context 'when date is within the first 7 days of the month' do
        it 'returns true' do
          expect(subject.first_of_month?(date: Date.parse('2023-09-03'))).to eq(true)
        end
      end

      context 'when date is after the first 7 days of the month' do
        it 'returns false' do
          expect(subject.first_of_month?(date: Date.parse('2023-09-08'))).to eq(false)
        end
      end
    end

    context 'when merchant is daily' do
      let(:merchant) { create(:merchant, disbursement_frequency: Merchant::DAILY_FREQUENCY) }

      context 'when date is exactly the first day of the month' do
        it 'returns true' do
          expect(subject.first_of_month?(date: Date.parse('2023-09-01'))).to eq(true)
        end
      end

      context 'when date is within the first 7 days of the month' do
        it 'returns false' do
          expect(subject.first_of_month?(date: Date.parse('2023-09-03'))).to eq(false)
        end
      end

      context 'when date is after the first 7 days of the month' do
        it 'returns false' do
          expect(subject.first_of_month?(date: Date.parse('2023-09-08'))).to eq(false)
        end
      end
    end
  end
end
