# frozen_string_literal: true

module Merchants
  class CalculateMinMonthlyFeeAmount
    private attr_reader :merchant, :date

    def initialize(merchant:, date:)
      @merchant = merchant
      @date = date
    end

    def call
      return 0 unless date.beginning_of_month > merchant.live_on.beginning_of_month

      [merchant.minimum_monthly_fee - total_last_month_fee_amount, 0].max
    end

    private

    attr_reader :merchant, :date

    def total_last_month_fee_amount
      last_month_disbursements.joins(:fees).sum('fees.amount')
    end

    def last_month_disbursements
      merchant.disbursements.where(
        'disbursements.created_at >= ? AND disbursements.created_at < ?', 
        date.last_month.beginning_of_month, 
        date.beginning_of_month
      )
    end
  end
end
