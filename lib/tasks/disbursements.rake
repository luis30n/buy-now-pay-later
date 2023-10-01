# frozen_string_literal: true

namespace :disbursements do
  desc 'Process past disbursements'
  task process_from_past_orders: :environment do
    orders = Order.undisbursed.order('created_at ASC')
    from = orders.first.created_at.to_date
    to = (orders.last.created_at + 7.days).to_date
    (from..to).each do |date|
      ::Disbursements::ProcessorWorker.new.perform(date.to_s)
    end
  end
end
