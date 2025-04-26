# frozen_string_literal: true

FactoryBot.define do
  factory :merchant do
    reference { 'merchant-awesome' }
    email { 'awsm.merchant@test.com' }
    live_on { '2023-09-27' }
    disbursement_frequency { Merchant::DAILY_FREQUENCY }
    minimum_monthly_fee { '9.99' }
  end
end
