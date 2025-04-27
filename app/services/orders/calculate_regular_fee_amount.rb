# frozen_string_literal: true

module Orders
  class CalculateRegularFeeAmount
    PERCENTAGES = [
      { percentage: '1.00', min: '0.00', max: '50.00' },
      { percentage: '0.95', min: '50.00', max: '300.00' },
      { percentage: '0.85', min: '300.00', max: Float::INFINITY }
    ].freeze

    private attr_reader :orders

    def initialize(orders:)
      @orders = orders
    end

    def call
      orders.reduce(BigDecimal('0.00')) do |sum, order|
        sum + fee_amount(order.amount)
      end
    end

    private

    def fee_amount(amount)
      (amount * BigDecimal(fee_percentage(amount)) / BigDecimal('100.00')).round(2)
    end

    def fee_percentage(amount)
      PERCENTAGES.find do |config|
        amount >= BigDecimal(config[:min]) && amount < BigDecimal(config[:max])
      end.fetch(:percentage)
    end
  end
end
