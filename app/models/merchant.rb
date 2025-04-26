# frozen_string_literal: true

class Merchant < ApplicationRecord
  DAILY_FREQUENCY = 'daily'
  WEEKLY_FREQUENCY = 'weekly'

  enum disbursement_frequency: {
    daily: DAILY_FREQUENCY,
    weekly: WEEKLY_FREQUENCY
  }
  has_many :disbursements, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception
end
