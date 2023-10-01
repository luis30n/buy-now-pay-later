# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    merchant { build(:merchant) }
    disbursement { nil }
    amount { '999' }
  end
end
