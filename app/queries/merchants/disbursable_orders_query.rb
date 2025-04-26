# frozen_string_literal: true

module Merchants
  class DisbursableOrdersQuery
    DISBURSEMENT_FREQUENCY_CONFIG = {
      ::Merchant::DAILY_FREQUENCY => 1,
      ::Merchant::WEEKLY_FREQUENCY => 7
    }.freeze

    def initialize(merchant:, date:)
      @merchant = merchant
      @date = date
    end

    def call
      merchant.orders.undisbursed.where(
        'created_at >= ? AND created_at < ?',
        disbursement_start_date, date
      )
    end

    private

    attr_reader :merchant, :date

    def disbursement_start_date
      date - disbursement_window.days
    end

    def disbursement_window
      DISBURSEMENT_FREQUENCY_CONFIG.fetch(merchant.disbursement_frequency)
    end
  end
end
