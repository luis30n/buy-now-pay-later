# frozen_string_literal: true

class Merchant < ApplicationRecord
  enum disbursement_frequency: {
    daily: 'daily',
    weekly: 'weekly'
  }
  DISBURSEMENT_FREQUENCY_CONFIG = {
    'daily' => 1,
    'weekly' => 7
  }.freeze

  has_many :disbursements, dependent: :restrict_with_exception
  has_many :orders, dependent: :restrict_with_exception

  def disbursable_orders(date:)
    orders.undisbursed.where(
      'created_at >= ? AND created_at  < ?',
      date - DISBURSEMENT_FREQUENCY_CONFIG.fetch(disbursement_frequency).days, date
    )
  end
end
