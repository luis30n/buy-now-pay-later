# frozen_string_literal: true

module Disbursements
  class ProcessorWorker
    include Sidekiq::Worker

    def perform(date = Date.today.to_s)
      @date = date

      merchant_ids = merchants.pluck(:id)

      merchant_ids.each do |merchant_id|
        CreatorWorker.perform_async(@date, merchant_id)
      end
    end

    private

    def merchants
      ::Merchants::EligibleForDisbursementQuery.new(date: @date).call
    end
  end
end
