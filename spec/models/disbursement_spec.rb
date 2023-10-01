# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Disbursement, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:merchant) }
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:fees) }
  end

  describe '#first_of_month?' do
    subject(:disbursement) do
      create(:disbursement, merchant:, created_at: Date.parse('2023-09-03'))
    end
    let!(:older_disbursement_from_merchant) do
      create(:disbursement, merchant:, created_at: Date.parse('2023-09-05'))
    end
    let!(:earlier_disbursement_from_other_merchant) do
      create(:disbursement, merchant: build(:merchant), created_at: Date.parse('2023-09-01'))
    end
    let(:merchant) { create(:merchant) }

    context 'when it is the first of the month for its merchant' do
      it 'returns true' do
        expect(disbursement.first_of_month?).to eq(true)
      end
    end

    context 'when it is not the first of the month for its merchant' do
      let!(:earlier_disbursement_from_merchant) do
        create(:disbursement, merchant:, created_at: Date.parse('2023-09-01'))
      end

      it 'returns false' do
        expect(disbursement.first_of_month?).to eq(false)
      end
    end
  end
end
