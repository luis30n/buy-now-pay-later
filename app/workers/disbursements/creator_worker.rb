# frozen_string_literal: true

module Disbursements
  class CreatorWorker
    include Sidekiq::Worker

    def perform(date, merchant_id)
      merchant = Merchant.find_by(id: merchant_id)

      return Rails.logger.info("Merchant with ID #{merchant_id} not found.") if merchant.blank?

      Disbursements::Creator.new(date:, merchant:).call
    end

    private

    def merchant(id)
      @merchant ||= Merchant.find_by(id:)
    end
  end
end
