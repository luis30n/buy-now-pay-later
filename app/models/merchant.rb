# frozen_string_literal: true

class Merchant < ApplicationRecord
  enum disbursement_frequency: {
    daily: 'daily',
    weekly: 'weekly'
  }
end
