# frozen_string_literal: true

FactoryBot.define do
  factory :disbursement do
    reference { SecureRandom.uuid }
    amount { '90.9' }
    merchant { build(:merchant) }
  end
end
