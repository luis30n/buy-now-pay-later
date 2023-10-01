# frozen_string_literal: true

module Disbursements
  class ProcessorWorker
    include Sidekiq::Worker

    def perform(date: Date.today.to_s)
      @date = Date.parse(date)

      merchants.find_each(batch_size: 100) do |merchant|
        ::Services::Disbursements::Creator.new(date: @date, merchant:).call
      end
    end

    private

    def merchants
      daily_merchants.or(weekly_merchants_for_weekday)
    end

    def daily_merchants
      Merchant.where(disbursement_frequency: 'daily')
    end

    def weekly_merchants_for_weekday
      Merchant
        .where(disbursement_frequency: 'weekly')
        .where('EXTRACT(DOW from live_on) = ?', @date.wday)
    end
  end
end
