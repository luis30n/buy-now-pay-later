# frozen_string_literal: true

class CreateMerchants < ActiveRecord::Migration[7.0]
  def change
    create_table :merchants do |t|
      t.string :reference
      t.string :email
      t.date :live_on
      t.string :disbursement_frequency
      t.decimal :minimum_monthly_fee, precision: 10, scale: 2

      t.timestamps
    end
  end
end
