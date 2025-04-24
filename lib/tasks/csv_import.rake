# frozen_string_literal: true

require 'csv'

namespace :csv_import do
  desc 'Import merchants from a CSV file'
  task merchants: :environment do
    next Rails.logger.info("There are already #{Merchant.count} in the database.") if Merchant.any?

    Rails.logger.info('Importing merchants from CSV...')

    merchants_file_path = Rails.root.join('data/merchants.csv')
    Merchant.transaction do
      CSV.foreach(merchants_file_path, headers: true, col_sep: ';') do |merchant_row|
        Merchant.create!(
          reference: merchant_row.fetch('reference'),
          email: merchant_row.fetch('email'),
          live_on: merchant_row.fetch('live_on'),
          disbursement_frequency: merchant_row.fetch('disbursement_frequency').downcase,
          minimum_monthly_fee: merchant_row.fetch('minimum_monthly_fee')
        )
      end
    end

    Rails.logger.info("Imported #{Merchant.count} merchants.")
  end

  desc 'Import orders from a CSV file'
  task orders: :environment do
    next Rails.logger.info("There are already #{Order.count} in the database.") if Order.any?

    Rails.logger.info('Importing orders from CSV...')

    orders_file_path = Rails.root.join('data/orders.csv')
    orders_attributes = []
    merchants_hash = Merchant.pluck(:reference, :id).to_h

    CSV.foreach(orders_file_path, headers: true, col_sep: ';') do |order_row|
      orders_attributes << {
        merchant_id: merchants_hash.fetch(order_row.fetch('merchant_reference')),
        amount: order_row.fetch('amount'),
        created_at: order_row.fetch('created_at')
      }
    end

    order_batches = orders_attributes.each_slice(100_000)
    order_batches.with_index do |orders_batch, index|
      Rails.logger.info("Inserting #{orders_batch.size} orders. Batch ##{index + 1} of #{order_batches.size}...")
      Order.insert_all(orders_batch)
    end

    Rails.logger.info("Imported #{Order.count} orders.")
  end
end
