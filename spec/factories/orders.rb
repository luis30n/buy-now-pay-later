# frozen_string_literal: true

FactoryBot.define do
  factory :order do
    merchant { nil }
    disbursement { nil }
    amount { '999' }
  end
end
