# frozen_string_literal: true

module Disbursements
  class ProcessorWorker
    include Sidekiq::Worker

    def perform(date = Date.today.to_s)
      @date = date

      merchant_ids.each do |merchant_id|
        CreatorWorker.perform_async(@date, merchant_id)
      end
    end

    private

    def merchant_ids
      daily_merchants.or(weekly_merchants_for_weekday).pluck(:id)
    end

    def daily_merchants
      Merchant.where(disbursement_frequency: 'daily')
    end

    def weekly_merchants_for_weekday
      Merchant
        .where(disbursement_frequency: 'weekly')
        .where('EXTRACT(DOW from live_on) = ?', @date.to_date.wday)
    end
  end
end
