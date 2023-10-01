# frozen_string_literal: true

FactoryBot.define do
  factory :fee do
    amount { '9.99' }
    disbursement { build(:disbursement) }
    category { 'regular' }
  end
end
