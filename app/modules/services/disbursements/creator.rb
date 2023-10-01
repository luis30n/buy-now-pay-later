# frozen_string_literal: true

# frozen_literal_string: true

module Services
  module Disbursements
    class Creator
      def initialize(date:, merchant:)
        @date = date
        @merchant = merchant
      end

      def call
        Disbursement.transaction do
          @disbursement = create_disbursement!
          create_regular_fee!
          create_min_monthly_fee!
        end
        disbursement
      end

      private

      attr_reader :date, :merchant, :disbursement

      def create_disbursement!
        Disbursement.create!(
          orders: disbursable_orders,
          merchant:,
          amount: disbursement_amount,
          created_at: date
        )
      end

      def create_regular_fee!
        Fee.create!(
          disbursement:,
          amount: regular_fee_amount,
          category: 'regular',
          created_at: date
        )
      end

      def create_min_monthly_fee!
        return unless disbursement.first_of_month?
        return if merchant.pending_min_monthly_fee_amount(date:).zero?

        Fee.create!(
          disbursement:,
          amount: merchant.pending_min_monthly_fee_amount(date:),
          category: 'min_monthly',
          created_at: date
        )
      end

      def disbursable_orders
        @disbursable_orders ||= merchant.disbursable_orders(date:)
      end

      def disbursement_amount
        # TODO: Charge the min monthly fee
        total_amount - regular_fee_amount
      end

      def regular_fee_amount
        @regular_fee_amount ||= disbursable_orders.reduce(BigDecimal('0.00')) do |sum, order|
          sum + order.fee_amount
        end
      end

      def total_amount
        @total_amount ||=
          BigDecimal(disbursable_orders.pluck(:amount).reduce(BigDecimal('0.00'), :+))
      end
    end
  end
end
