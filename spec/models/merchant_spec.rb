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
end
