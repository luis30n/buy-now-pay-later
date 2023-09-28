# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Order, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:disbursement) }
    it { is_expected.to belong_to(:merchant) }
  end
end
