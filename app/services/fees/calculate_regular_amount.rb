# frozen_string_literal: true

module Fees
  class CalculateRegularAmount
    private attr_reader :orders

    def initialize(orders:)
      @orders = orders
    end

    def call
      orders.reduce(BigDecimal('0.00')) do |sum, order|
        sum + order.fee_amount
      end
    end
  end
end
