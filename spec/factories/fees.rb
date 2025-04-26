# frozen_string_literal: true

FactoryBot.define do
  factory :fee do
    amount { '9.99' }
    disbursement { build(:disbursement) }
    category { Fee::REGULAR_CATEGORY }
  end
end
