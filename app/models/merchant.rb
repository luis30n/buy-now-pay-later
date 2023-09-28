# frozen_string_literal: true

class Merchant < ApplicationRecord
  enum disbursement_frequency: {
    daily: 'daily',
    weekly: 'weekly'
  }

  has_many :disbursements, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception
end
