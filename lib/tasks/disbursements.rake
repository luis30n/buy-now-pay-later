# frozen_string_literal: true

namespace :disbursements do
  desc 'Process past disbursements'
  task process_from_past_orders: :environment do
    orders = Order.undisbursed.order('created_at ASC')
    next Rails.logger.info("There aren't any undisbursed orders") if orders.empty?

    from = orders.first.created_at.to_date
    to = (orders.last.created_at + 7.days).to_date
    (from..to).each do |date|
      ::Disbursements::ProcessorWorker.new.perform(date.to_s)
    end
  end

  desc 'Generate stats'
  task generate_stats: :environment do
    require 'csv'
    disbursements_query = Disbursement.group('EXTRACT(YEAR FROM created_at)')
                                      .select("EXTRACT(YEAR FROM created_at) as year,
              COUNT(*) as total_disbursements,
              SUM(amount) as total_disbursement_amount")

    regular_fees_query = Fee.where(category: 'regular')
                            .group('EXTRACT(YEAR FROM created_at)')
                            .select("EXTRACT(YEAR FROM created_at) as year,
                       SUM(amount) as total_regular_fee_amount")
    min_monthly_fees_query = Fee.where(category: 'min_monthly')
                                .group('EXTRACT(YEAR FROM created_at)')
                                .select("EXTRACT(YEAR FROM created_at) as year,
                            COUNT(*) as total_monthly_fees_count,
                            SUM(amount) as total_monthly_fee_amount")

    sql_query = <<~SQL
      SELECT
        disbursements.year,
        total_disbursements,
        total_disbursement_amount,
        regular_fees.total_regular_fee_amount as total_regular_fee_amount,
        min_monthly_fees.total_monthly_fees_count as total_monthly_fees_count,
        min_monthly_fees.total_monthly_fee_amount as total_monthly_fee_amount
      FROM (
        #{disbursements_query.to_sql}
      ) AS disbursements
      LEFT JOIN (
        #{regular_fees_query.to_sql}
      ) AS regular_fees ON disbursements.year = regular_fees.year
      LEFT JOIN (
        #{min_monthly_fees_query.to_sql}
      ) AS min_monthly_fees ON disbursements.year = min_monthly_fees.year
    SQL

    combined_data = ActiveRecord::Base.connection.execute(sql_query)
    report_file_path = Rails.root.join('data/stats.csv')

    report_headers = [
      'Year',
      'Number of disbursements',
      'Amount disbursed to merchants',
      'Amount of order fees',
      'Number of monthly fees charged (From minimum monthly fee)',
      'Amount of monthly fee charged (From minimum monthly fee)'
    ]

    CSV.open(report_file_path, 'w', write_headers: true, headers: report_headers) do |csv|
      combined_data.each do |row|
        csv << row.values
      end
    end

    Rails.logger.info("CSV file 'data/stats.csv' has been generated.")
  end
end
