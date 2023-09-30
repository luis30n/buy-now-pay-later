# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Fee, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:disbursement) }
  end

  describe 'validations' do
    it 'defines a type enum' do
      expect(subject).to define_enum_for(:category).with_values(
        regular: 'regular',
        monthly_min: 'monthly_min'
      ).backed_by_column_of_type(:string)
    end
  end
end
