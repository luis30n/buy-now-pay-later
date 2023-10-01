# frozen_string_literal: true

class CreateFees < ActiveRecord::Migration[7.0]
  def change
    create_table :fees do |t|
      t.decimal :amount, precision: 10, scale: 2
      t.references :disbursement, null: false, foreign_key: true
      t.string :category, null: false, default: 'regular'
      t.timestamps
    end
  end
end
