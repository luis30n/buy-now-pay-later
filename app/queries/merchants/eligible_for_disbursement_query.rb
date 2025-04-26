# frozen_string_literal: true

module Merchants
  class EligibleForDisbursementQuery
    private attr_reader :date

    def initialize(date:)
      @date = date.to_date
    end

    def call
      daily_merchants.or(weekly_merchants_for_weekday)
    end

    private

    def daily_merchants
      Merchant.where(disbursement_frequency: Merchant::DAILY_FREQUENCY)
    end

    def weekly_merchants_for_weekday
      Merchant
        .where(disbursement_frequency: Merchant::WEEKLY_FREQUENCY)
        .where('EXTRACT(DOW from live_on) = ?', date.wday)
    end
  end
end
