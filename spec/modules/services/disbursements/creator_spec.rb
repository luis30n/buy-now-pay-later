# frozen_string_literal: true

RSpec.describe Services::Disbursements::Creator do
  subject(:creator) do
    described_class.new(date:, merchant:)
  end
  let(:date) { Date.parse('2023-10-02') }
  let(:merchant) { create(:merchant, disbursement_frequency: 'weekly') }

  describe '#call' do
    let!(:order1) do
      create(:order, merchant:, amount: 122, created_at: Date.parse('2023-09-29'))
    end
    let!(:order2) do
      create(:order, merchant:, amount: 30, created_at: Date.parse('2023-09-28'))
    end
    let!(:order3) do
      create(:order, merchant:, amount: 302, created_at: Date.parse('2023-09-01'))
    end

    it 'creates a disbursement' do
      expect { creator.call }.to change(Disbursement, :count).from(0).to(1)
    end

    it 'sets the right disbursement amount' do
      disbursement = creator.call

      expect(disbursement.amount).to eq(150.54)
    end

    it 'creates a fee' do
      expect { creator.call }.to change(Fee, :count).from(0).to(1)
    end

    it 'sets the right fee attributes' do
      creator.call
      fee = Fee.last

      aggregate_failures do
        expect(fee.category).to eq('regular')
        expect(fee.amount).to eq(1.46)
      end
    end
  end
end
