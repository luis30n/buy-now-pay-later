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

  private

  def total_last_month_fee_amount(date)
    last_month_disbursements(date).joins(:fees).sum('fees.amount')
  end

  def last_month_disbursements(date)
    from = date.last_month.beginning_of_month
    to = date.beginning_of_month
    disbursements.where('disbursements.created_at >= ? AND disbursements.created_at < ?', from, to)
  end
end
