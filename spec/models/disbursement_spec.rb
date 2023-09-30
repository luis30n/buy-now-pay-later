# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Disbursement, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:merchant) }
    it { is_expected.to have_many(:orders) }
    it { is_expected.to have_many(:fees) }
  end
end
