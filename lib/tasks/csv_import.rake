# frozen_string_literal: true

namespace :csv_import do
  desc 'Import merchants from a CSV file'
  task merchants: :environment do
    require 'csv'

    return Rails.logger.info("There are already #{Merchant.count} in the database.") if Merchant.any?

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
end
