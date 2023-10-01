# frozen_string_literal: true

class Order < ApplicationRecord
  PERCENTAGES = [
    { percentage: '1.00', min: '0.00', max: '50.00' },
    { percentage: '0.95', min: '50.00', max: '300.00' },
    { percentage: '0.85', min: '300.00', max: Float::INFINITY }
  ].freeze

  belongs_to :merchant
  belongs_to :disbursement, optional: true

  scope :undisbursed, -> { where(disbursement_id: nil) }

  def fee_amount
    (amount * BigDecimal(fee_percentage) / BigDecimal('100.00')).round(2)
  end

  private

  def fee_percentage
    PERCENTAGES.find do |config|
      amount >= BigDecimal(config[:min]) && amount < BigDecimal(config[:max])
    end.fetch(:percentage)
  end
end
